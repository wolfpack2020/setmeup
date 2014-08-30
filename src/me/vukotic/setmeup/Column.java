package me.vukotic.setmeup;

public class Column {
	Long index=0L;
	Boolean key=false;
	String name="";
	String type="s";
	public String toString(){
		return "col: "+name+" type:"+type;
	}
}
