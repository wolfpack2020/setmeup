package me.vukotic.setmeup;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Date;
import java.util.List;
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
public class creator extends HttpServlet {

	private static final Logger log = Logger.getLogger(creator.class.getName());
	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	public Boolean projectExist(String name){
		log.warning("checking if project "+name+" already exists.");
		Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, name);
		Query qp = new Query("Project").setFilter(pn);
		Entity pr = datastore.prepare(qp).asSingleEntity();	
		if (pr==null) {
			log.warning("it does not.");
			return false;
		} else {
			log.warning("it does.");
			return true;
		}
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		log.warning("creator got POSTed ...");

		StringBuilder sb = new StringBuilder();
		BufferedReader br = req.getReader();
		String str;
		while ((str = br.readLine()) != null) {
			sb.append(str);
		}

		JSONObject p = null;
		try {
			log.warning(sb.toString());
			p = new JSONObject(sb.toString());
		} catch (Exception e) {
			log.severe("could not parse to JSONObject");
			log.severe(sb.toString());
			log.severe(e.getMessage());
			return;
		}
		
		if (projectExist(p.getString("title"))==true) {
			resp.getWriter().print("was not created, as it already exists.");
			return;
		}
		
		Entity project = new Entity("Project");
		Date currTime = new Date();
		project.setProperty("timestamp", currTime);
		project.setProperty("name", p.getString("title"));

		Date date = new Date(p.getLong("from"));
		project.setProperty("startDate", date);
		date = new Date(p.getLong("to"));
		project.setProperty("endDate", date);

		datastore.put(project);
		JSONArray cols = p.getJSONArray("cols");
		for (int i = 0; i < cols.length(); i++) {
			JSONObject col = cols.getJSONObject(i);
			Entity column = new Entity("Column", project.getKey());
			column.setProperty("name", col.getString("name"));
			column.setProperty("key", col.getBoolean("key"));
			column.setProperty("type", col.getString("type"));
			column.setProperty("index", col.getInt("index"));
			datastore.put(column);
		}

		resp.getWriter().print("successfully created.");

	}
	
	// returns all the results for a given project name
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		log.warning("creator got a GET ...");
		resp.setContentType("application/json");
		
		if (req.getParameter("what").equals("project_names")){
			Query q = new Query("Project");
			List<Entity> lRes = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			log.warning("returns project names: " + lRes.size());
			JSONObject data = new JSONObject();
			JSONArray results = new JSONArray();
			for (Entity result : lRes) {
				results.put(result.getProperty("name"));
			}
			data.put("projects", results);
			resp.getWriter().print(data);
			return;
		}
		
		if (req.getParameter("what").equals("project_details")){
			log.warning("returns project details: " + req.getParameter("project"));
			Project p=ProjectCache.getProject(req.getParameter("project"));
			resp.getWriter().print(p.getJSON());
			return;
		}
		
	}
}
