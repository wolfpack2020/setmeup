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

		// if (req.getParameter("reset") != null) {
		// log.warning("cleaning the data ...");
		// Query q = new Query("Data").setKeysOnly();
		// List<Entity> lRes =
		// datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		// for (Entity e:lRes)
		// datastore.delete(e.getKey());
		// return;
		// }

		
		
		if (req.getParameter("result") != null) {
			log.warning("receiving the data ...");
			JSONObject json_result = new JSONObject(req.getParameter("result"));

			// looking up  that project
			String proj = json_result.getString("project");
			Project p=ProjectCache.getProject(proj);
			if (p==null) {
				resp.getWriter().print("No session of that name found.");
				return;
			}
					
			Entity result = new Entity("Data_"+p.name, p.dsKey);
			result.setProperty("timestamp", new Date());
			
			Iterator<?> jCols = json_result.keys();

			while (jCols.hasNext()) {
				String jCol = (String) jCols.next();
				if (jCol.equals("project"))
					continue;
				Boolean found = false;
				for (Map.Entry<String, Column> entry : p.columns.entrySet()) {
					String colName = entry.getKey();
				    Column col = entry.getValue();
					if (jCol.equals(colName)) {
						if (col.type.equals("s"))
							result.setProperty(jCol, json_result.getString(jCol));
						if (col.type.equals("b"))
							result.setProperty(jCol, json_result.getBoolean(jCol));
						if (col.type.equals("i"))
							result.setProperty(jCol, json_result.getInt(jCol));
						if (col.type.equals("f"))
							result.setProperty(jCol, json_result.getDouble(jCol));
						if (col.type.equals("d"))
							result.setProperty(jCol, new Date(json_result.getLong(jCol)));
						found = true;
					}
				}
				if (!found)
					log.warning("could not find a column named: " + jCol);
			}

			Entity toStore=p.getEntity(result);
			if (toStore==null){
				resp.getWriter().print("At least one of the key columns is missing. Not storing the result.");
				return;
			}
			datastore.put(toStore);
		}

	}

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		log.warning("repeater to deliver the data ...");

		resp.setContentType("application/json");
		JSONObject data = new JSONObject();
		JSONArray results = new JSONArray();
		JSONArray headers = new JSONArray();
		List<String> h = new ArrayList<String>();

		if (req.getParameter("project") != null) {

			// looking up columns of that project
			String proj = req.getParameter("project");
			Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, proj);
			Query qp = new Query("Project").setKeysOnly().setFilter(pn);
			Entity pr = datastore.prepare(qp).asSingleEntity();
			if (pr == null)
				return;
			Query cq = new Query("Column").setAncestor(pr.getKey());
			List<Entity> lColumns = datastore.prepare(cq).asList(FetchOptions.Builder.withDefaults());

			Query q = new Query("Data_"+proj).setAncestor(pr.getKey());
			List<Entity> lData = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			log.warning("results: " + lData.size());

			for (Entity col : lColumns)
				h.add((String) col.getProperty("name"));

			for (Entity result : lData) {
				JSONArray res = new JSONArray();
				Map<String, Object> l = result.getProperties();
				for (Entity col : lColumns) {
					for (Map.Entry<String, Object> entry : l.entrySet()) {
						String k = entry.getKey();

						if (!k.equals((String) col.getProperty("name")))
							continue;

						String ctype = (String) col.getProperty("type");

						Object v = entry.getValue();
						if (ctype.equals("s"))
							res.put((String) v);
						if (ctype.equals("i"))
							res.put((Long) v);
						if (ctype.equals("f"))
							res.put((Double) v);
						if (ctype.equals("b"))
							res.put((Boolean) v);
						if (ctype.equals("d"))
							res.put((Date) v);
					}
				}
				results.put(res);
			}

		}
		data.put("results", results);

		for (String he : h)
			headers.put(new JSONObject().put("title", he));
		data.put("headers", headers);
		resp.getWriter().print(data);

	}
}
