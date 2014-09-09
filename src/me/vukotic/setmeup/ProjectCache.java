package me.vukotic.setmeup;

import java.util.HashMap;
import java.util.List;
import java.util.logging.Logger;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Key;

public class ProjectCache {

	private static final Logger log = Logger.getLogger(ProjectCache.class.getName());
	private static HashMap<String, Project> cachedProjects= new HashMap<String,Project>();
	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	public static Project getProject(String projectName){
		// if have it cached
		if (cachedProjects.containsKey(projectName)){
			return cachedProjects.get(projectName);
		}else{
			// load it from storage
			Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, projectName);
			Query qp = new Query("Project").setKeysOnly().setFilter(pn);
			Entity pr = datastore.prepare(qp).asSingleEntity();
			if (pr == null){
				log.warning("Project with name "+projectName+" does not exist in the datastore");
				return null;
			}else{
				Project p=new Project(projectName);
				cachedProjects.put(projectName, p);
				return p;
			}
		}
	}
	
	public static void deleteProject(String projectName){
		Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, projectName);
		Query qp = new Query("Project").setKeysOnly().setFilter(pn);
		Entity pr = datastore.prepare(qp).asSingleEntity();			
		if (pr == null){
			log.warning("Project with name "+projectName+" does not exist in the datastore");
			return;
		}else{
			Key pk=pr.getKey();
			datastore.delete(pk);
			
			Query q = new Query("Column").setAncestor(pk);
			List<Entity> lCol = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			for (Entity c : lCol) datastore.delete(c.getKey());

			q = new Query("Data_"+projectName);
			List<Entity> lC = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			for (Entity c : lC) datastore.delete(c.getKey());
		}
		
	}
	
}
