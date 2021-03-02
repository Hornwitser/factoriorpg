"use strict";
const path = require("path");
const fs = require("fs-extra");
const libPlugin = require("@clusterio/lib/plugin");

class MasterPlugin extends libPlugin.BaseMasterPlugin {
	async init() {
		this.rpgData = null;

		await this.loadData();
		this.autosave = setInterval(() => {
			this.saveData().catch(err => this.logger.error(
				`Error handling autosaving data:\n${err.stack}`
			));
		}, 5 * 60 * 1000);
	}

	async loadData() {
		let filePath = path.join(this.master.config.get("master.database_directory"), "rpg", "data.json");
		let content;
		try {
			content = await fs.readFile(filePath);
		} catch (err) {
			if (err.code === "ENOENT") {
				this.logger.info("data file not found, starting from a blank state");
				this.rpgData = new Map();
				return;
			}
			throw err;
		}
		this.rpgData = new Map(JSON.parse(content));
	}

	async saveData() {
		if (!this.rpgData) {
			return;
		}
		let filePath = path.join(this.master.config.get("master.database_directory"), "rpg", "data.json");
		let tmpFile = `${filePath}.tmp`
		await fs.outputFile(tmpFile, JSON.stringify([...this.rpgData.entries()], null, 4));
		await fs.rename(tmpFile, filePath);
	}

	async onShutdown() {
		clearInterval(this.autosave);
		await this.saveData();
	}

	async loadPlayerDataRequestHandler(message) {
		let { player, instance_name } = message.data;
		if (this.rpgData.has(player)) {
			this.logger.info(`Loading data for ${player} on server ${instance_name}`);
			return { data: this.rpgData.get(player) };
		}

		this.logger.info(`New player ${player} on server ${instance_name}`);
		return { data: {} };
	}

	async savePlayerDataEventHandler(message) {
		let { instance_name, data } = message.data;
		let name = data["name"];
		delete data["name"];

		this.logger.info(`Saving data for ${name} from server ${instance_name}`);
		let entry = this.rpgData.get(name);
		if (!entry) {
			entry = {};
			this.rpgData.set(name, entry);
		}
		for (let [key, value] of Object.entries(data)) {
			if (!Object.prototype.hasOwnProperty.call(entry, key)) {
				entry[key] = 0;
			}
			entry[key] += value;
		}
	}
}

module.exports = {
	MasterPlugin,
};
