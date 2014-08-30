package me.vukotic.setmeup;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

public class Project {

	private static final Logger log = Logger.getLogger(Project.class.getName());
	String name;
	Key dsKey;
	Date startDate;
	Date endDate;
	Date created;
	
	HashMap<String, Column> columns=new HashMap<String, Column>();
	private static DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	Project(String n){
		name=n;
		load();
	}
	
	void load(){
		Filter pn = new FilterPredicate("name", FilterOperator.EQUAL, name);
		Query qp = new Query("Project").setFilter(pn);
		Entity pr = datastore.prepare(qp).asSingleEntity();	
		dsKey=pr.getKey();
		startDate=(Date) pr.getProperty("startDate");
		endDate=(Date) pr.getProperty("endDate");
		created=(Date) pr.getProperty("timestamp");
		log.warning("loaded project created at: "+created.toString()); 
		loadColumns();
	}
	
	void loadColumns(){
		Query q = new Query("Column").setAncestor(dsKey);
		List<Entity> lCol = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		for (Entity c : lCol) {
			Column column=new Column();
			column.name=(String) c.getProperty("name");
			column.key=(Boolean) c.getProperty("key");
			column.index=(Long) c.getProperty("index");
			column.type=(String) c.getProperty("type");
			log.warning(column.toString());
			columns.put(column.name, column);
		}
		log.warning("loaded "+ columns.size() +" columns."); 
	}

	public Entity getEntity(Entity result) {
		// check if there is an entity with the same values in key columns
		// if not return the parameter entity
		// if yes copy the values from the parameter entity to the found one and return that one.

		Query q = new Query("Data").setAncestor(dsKey);
		List<Entity> lRows = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());

		log.warning("lRows size before:"+lRows.size());
		
		// loop over project's key columns
		for (Map.Entry<String, Column> eCol : columns.entrySet()){
			Column c=eCol.getValue();
			String cn=eCol.getKey();
			if (c.key==false) continue;
			// if key column is missing dump result
			if (result.getProperty(cn)==null) return null;
			// check if the key has the same value
			Iterator<Entity> i = lRows.iterator();
			while (i.hasNext()) {  
				Entity row = i.next(); 
				log.warning("comparing values for column:"+cn+" v1:"+result.getProperty(cn)+" v2:"+row.getProperty(cn));
				if (! result.getProperty(cn).equals(row.getProperty(cn))) {
					i.remove();
					log.warning("removed");
				}
			}
		}
		log.warning("lRows size after:"+lRows.size());
		if (lRows.size()==1) {
			Entity r=lRows.get(0);
			r.setPropertiesFrom(result);
			return r;
		}else{
			return result;
		}
		
	}
	
}
