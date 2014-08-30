package me.vukotic.setmeup;

import java.util.HashMap;

import org.mortbay.log.Log;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

public class ProjectCache {

	HashMap<String, Project> cachedProjects= new HashMap<String,Project>();
	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	Project getProject(String projectName){
		// if have it cached
		if (cachedProjects.containsKey(projectName)){
			return cachedProjects.get(projectName);
		}else{
			// load it from storage
			Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, projectName);
			Query qp = new Query("Project").setKeysOnly().setFilter(pn);
			Entity pr = datastore.prepare(qp).asSingleEntity();
			if (pr == null){
				Log.warn("Project with name "+projectName+" does not exist in the datastore");
				return null;
			}else{
				Project p=new Project(projectName);
				cachedProjects.put(projectName, p);
				return p;
			}
		}
	}
	
}
