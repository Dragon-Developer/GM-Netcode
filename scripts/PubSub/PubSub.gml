function PubSub() constructor {
	self.topics = {};
	static getTopic = function(_name) {
		if (!hasTopic(_name)) return undefined;
		return topics[$ _name];
	}
	static createTopic = function(_name) {
		if (!hasTopic(_name)) {
			topics[$ _name] = new PubSub_Topic();
		}
		return topics[$ _name];
	}
	static hasTopic = function(_name) {
		return struct_exists(topics, _name);
	}
	static removeTopic = function(_name) {
	    if (!struct_exists(topics, _name)) return;
	    struct_remove(topics, _name);
	}
	static removeAllTopics = function() {
	    topics = {};
	}
	static publish = function(_topic, _data) {
		if (!hasTopic(_topic)) return;
	    getTopic(_topic).publish(_data);
	}
	static unsubscribeAll = function(_id) {
		idRemoved = _id;
		array_foreach(struct_get_names(topics), function(_name) {
			var _topic = topics[$ _name];
			_topic.unsubscribe(idRemoved);
		});
	}
}

function PubSub_Topic(_id, _func) constructor {
	self.subscribers = {};
	static subscribe = function(_id, _func) {
		subscribers[$ _id] = _func;
	}
	static unsubscribe = function(_id) {
		struct_remove(subscribers, _id);
		return true;
	}
	static isSubscribed = function(_id) {
		return struct_exists(subscribers, _id);
	}
	static publish = function(_data) {
		data = _data;
		struct_foreach(subscribers, function(_id, _func) {
			_func(real(_id), data);
		});
	}
}