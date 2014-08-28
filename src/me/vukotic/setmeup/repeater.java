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
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

@SuppressWarnings("serial")
public class repeater extends HttpServlet {

	private static final Logger log = Logger.getLogger(repeater.class.getName());

	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		log.warning("repeater got POSTed ...");

//		if (req.getParameter("reset") != null) {
//			log.warning("cleaning the data ...");
//			Query q = new Query("Data").setKeysOnly();
//			List<Entity> lRes = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
//			for (Entity e:lRes)
//				datastore.delete(e.getKey());
//			return;
//		}

		if (req.getParameter("result") != null) {
			log.warning("receiving the data ...");
			JSONObject json_result = new JSONObject(req.getParameter("result"));

			// looking up columns of that project
			String proj=json_result.getString("project");
			Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, proj);
			Query qp = new Query("Project").setKeysOnly().setFilter(pn);
			Entity prkey=datastore.prepare(qp).asSingleEntity();
			Query q = new Query("Column").setAncestor(prkey.getKey());
			
			List<Entity> lRes = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			
			Date currTime = new Date();
			Entity result = new Entity("Data");			
			result.setProperty("d_timestamp", currTime);
			
			Iterator<?> keys = json_result.keys();

			while (keys.hasNext()) {
				String key = (String) keys.next();
				Boolean found=false;
				for (Entity c :lRes){
					if (key.equals(c.getProperty("name"))){
						String pt=(String) c.getProperty("type");
						if (pt.equals("s")) result.setProperty(key, json_result.getString(key));
						if (pt.equals("b")) result.setProperty(key, json_result.getBoolean(key));
						if (pt.equals("i")) result.setProperty(key, json_result.getInt(key));
						if (pt.equals("f")) result.setProperty(key, json_result.getDouble(key));
						if (pt.equals("d")) result.setProperty(key, new Date(json_result.getLong(key)) );
						found=true;
					}
				}
				if (!found) log.warning("could not find a column named: "+key);
			}

			datastore.put(result);
		}

	}

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		log.warning("repeater to deliver the data ...");

		resp.setContentType("application/json");
		if (req.getParameter("project") == null) return;
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
