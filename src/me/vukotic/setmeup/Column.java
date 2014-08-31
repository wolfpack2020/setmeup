package me.vukotic.setmeup;

import org.json.JSONObject;

public class Column {
	Long index = 0L;
	Boolean key = false;
	String name = "";
	String type = "s";

	public String toString() {
		return "col: " + name + " type:" + type;
	}

	JSONObject getJSON() {
		JSONObject data = new JSONObject();
		data.put("name", name);
		data.put("key", key);
		data.put("index", index);
		data.put("type", type);
		return data;
	}
}
