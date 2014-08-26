package me.vukotic.setmeup;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Query;

@SuppressWarnings("serial")
public class repeater extends HttpServlet {

	private static final Logger log = Logger.getLogger(repeater.class.getName());

	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		log.warning("repeater got POSTed ...");

		if (req.getParameter("reset") != null) {
			log.warning("cleaning the data ...");
			Query q = new Query("Data").setKeysOnly();
			List<Entity> lRes = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			for (Entity e:lRes)
				datastore.delete(e.getKey());
			return;
		}

		if (req.getParameter("result") != null) {
			log.warning("receiving the data ...");
			JSONObject json = new JSONObject(req.getParameter("result"));

			Date currTime = new Date();
			Entity result = new Entity("Data");
			result.setProperty("d_timestamp", currTime);
			Iterator<?> keys = json.keys();

			while (keys.hasNext()) {
				String key = (String) keys.next();
				if (key.startsWith("s_"))
					result.setProperty(key, json.getString(key));
				if (key.startsWith("b_"))
					result.setProperty(key, json.getBoolean(key));
				if (key.startsWith("i_"))
					result.setProperty(key, json.getInt(key));
				if (key.startsWith("d_"))
					result.setProperty(key,new Date(json.getLong(key)) );
			}

			datastore.put(result);
		}

	}

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		log.warning("repeater to deliver the data ...");

		resp.setContentType("application/json");

		Query q = new Query("Data");
		List<Entity> lRes = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		log.warning("results: " + lRes.size());
		JSONObject data=new JSONObject();
		JSONArray results = new JSONArray();
		JSONArray headers = new JSONArray();
		List<String> h = new ArrayList<String>();
		for (Entity result : lRes) {
			Map<String, Object> l = result.getProperties();
			JSONArray res = new JSONArray();

			for (Map.Entry<String, Object> entry : l.entrySet()) {
				String k=entry.getKey();
				if (!h.contains(k)) h.add(k);
				Object v=entry.getValue();
				if (k.startsWith("s_")) res.put((String)v);
				if (k.startsWith("i_")) res.put((Long)v);
				if (k.startsWith("b_")) res.put((Boolean)v);
				if (k.startsWith("d_")) res.put((Date)v);
			}
			results.put(res);
		}
		data.put("results", results);
		
		for (String he:h) 
			headers.put(new JSONObject().put("title",he.substring(2)));
		data.put("headers", headers);
		resp.getWriter().print(data);

	}
}
