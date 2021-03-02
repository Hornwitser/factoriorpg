"use strict";
const libPlugin = require("@clusterio/lib/plugin");


class InstancePlugin extends libPlugin.BaseInstancePlugin {
	async init() {
		this.instance.server.on("ipc-factoriorpg", event => {
			this.handleEvent(event).catch(err => this.logger.error(
				`Error handling event:\n${err.stack}`
			));
		});
	}

	async handleEvent(event) {
		if (event.type === "loadsave") {
			let result = await this.info.messages.loadPlayerData.send(this.instance,
				{ player: event.player, instance_name: this.instance.name }
			);

			let data = result.data;
			let json = JSON.stringify({ ...data, "playername": event.player });
			this.logger.verbose(`loaddata ${json}`);
			await this.sendRcon(`/loaddata ${json}`, true);

		} else if (event.type === "savedata") {
			this.logger.verbose(`savedata ${JSON.stringify(event.data)}`);
			this.info.messages.savePlayerData.send(this.instance,
				{ data: event.data, instance_name: this.instance.name }
			);
		}
	}
}

module.exports = {
	InstancePlugin,
};
