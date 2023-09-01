package My.NewsService;

// -----( IS Java Code Template v1.2

import com.wm.data.*;
import com.wm.util.Values;
import com.wm.app.b2b.server.Service;
import com.wm.app.b2b.server.ServiceException;
// --- <<IS-START-IMPORTS>> ---
// --- <<IS-END-IMPORTS>> ---

public final class util

{
	// ---( internal utility methods )---

	final static util _instance = new util();

	static util _newInstance() { return new util(); }

	static util _cast(Object o) { return (util)o; }

	// ---( server methods )---




	public static final void getYesterdayIsoDate (IData pipeline)
        throws ServiceException
	{
		// --- <<IS-START(getYesterdayIsoDate)>> ---
		// @sigtype java 3.5
		// [o] field:0:required yesterday
		final java.util.Calendar cal = java.util.Calendar.getInstance();
		cal.add(java.util.Calendar.DATE, -1);
		java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd");
		// pipeline
		IDataCursor pipelineCursor = pipeline.getCursor();
		IDataUtil.put( pipelineCursor, "yesterday", ""+formatter.format(cal.getTime()) );
		pipelineCursor.destroy();
		// --- <<IS-END>> ---

                
	}
}

