"use strict";
const libLink = require("@clusterio/lib/link");


module.exports = {
	name: "factoriorpg",
	title: "Factorio RPG",
	description: "RPG mechanics in Factorio.",
	masterEntrypoint: "master",
	instanceEntrypoint: "instance",

	messages: {
		savePlayerData: new libLink.Event({
			type: "factoriorpg:save_player_data",
			links: ["instance-slave", "slave-master"],
			forwardTo: "master",
			eventProperties: {
				"data": { type: "object" },
				"instance_name": { type: "string" },
			},
		}),
		loadPlayerData: new libLink.Request({
			type: "factoriorpg:load_player_data",
			links: ["instance-slave", "slave-master"],
			forwardTo: "master",
			requestProperties: {
				"player": { type: "string" },
				"instance_name": { type: "string" },
			},
			responseProperties: {
				"data": { type: "object" },
			},
		}),
	},
};
