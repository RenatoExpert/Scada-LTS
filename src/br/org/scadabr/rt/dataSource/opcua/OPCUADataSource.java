package br.org.scadabr.rt.dataSource.opcua;

import java.util.ArrayList;
import java.util.logging.Level;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jinterop.dcom.common.JISystem;

import br.org.scadabr.vo.dataSource.opcua.OPCUADataSourceVO;
import br.org.scadabr.vo.dataSource.opcua.OPCUAPointLocatorVO;

import com.serotonin.mango.DataTypes;
import com.serotonin.mango.rt.dataImage.DataPointRT;
import com.serotonin.mango.rt.dataImage.PointValueTime;
import com.serotonin.mango.rt.dataImage.SetPointSource;
import com.serotonin.mango.rt.dataImage.types.MangoValue;
import com.serotonin.mango.rt.dataSource.PollingDataSource;
import com.serotonin.web.i18n.LocalizableMessage;

import java.util.concurrent.TimeUnit;
/*
import org.apache.plc4x.java.api.PlcConnection;
import org.apache.plc4x.java.api.PlcDriverManager;
import org.apache.plc4x.java.api.messages.PlcReadResponse;
import org.apache.plc4x.java.api.messages.PlcReadRequest;
*/

public class OPCUADataSource extends PollingDataSource {
	private final Log LOG = LogFactory.getLog(OPCUADataSource.class);
	public static final int POINT_READ_EXCEPTION_EVENT = 1;
	public static final int DATA_SOURCE_EXCEPTION_EVENT = 2;
	public static final int POINT_WRITE_EXCEPTION_EVENT = 3;
	private final OPCUADataSourceVO<?> vo;
	private int timeoutCount = 0;
	private int timeoutsToReconnect = 3;

	public OPCUADataSource(OPCUADataSourceVO<?> vo) {
		super(vo);
		this.vo = vo;
		JISystem.getLogger().setLevel(Level.OFF);
	}

	private String getData(String node) {
		/*
		try {
			String server = this.vo.getEndpoint();
			PlcConnection connection = PlcDriverManager.getDefault()
				.getConnectionManager()
				.getConnection(server);
			PlcReadRequest.Builder builder = connection.readRequestBuilder();
			builder.addTagAddress("my_tag", node);
			PlcReadResponse response = builder.build()
				.execute()
				.get(5000, TimeUnit.MILLISECONDS);
			String tagName = response.getTagNames().iterator().next();
			String value = response.getObject(tagName).toString();
			connection.close();
			//return value;
		} catch(Exception ex) {
			System.out.println("Error on getData() method");
		}
		*/
		return "5";
	}	

	@Override
	protected void doPoll(long time) {
		for (DataPointRT dataPoint : dataPoints) {
			OPCUAPointLocatorVO dataPointVO = dataPoint.getVO().getPointLocator();
			String node = dataPointVO.getTagUrl();
			MangoValue mangoValue = null;
			String value = "0";
			try {
				value = getData(node); 
				mangoValue = MangoValue.stringToValue(value, dataPointVO.getDataTypeId());
				dataPoint.updatePointValue(new PointValueTime(mangoValue, time));
				setPointValue(dataPoint, new PointValueTime(value, time), null);
			} catch (Exception e) {
				raiseEvent(
					POINT_READ_EXCEPTION_EVENT,
					time,
					true,
					new LocalizableMessage("event.exception2", vo.getName(), e.getMessage())
				);
			}
		}
	}

	@Override
	public void setPointValue(DataPointRT dataPoint, PointValueTime valueTime, SetPointSource source) {
		String tag = ((OPCUAPointLocatorVO) dataPoint.getVO().getPointLocator()).getTag();
		Object value = null;
		if (dataPoint.getDataTypeId() == DataTypes.NUMERIC)
			value = valueTime.getDoubleValue();
		else if (dataPoint.getDataTypeId() == DataTypes.BINARY)
			value = valueTime.getBooleanValue();
		else if (dataPoint.getDataTypeId() == DataTypes.MULTISTATE)
			value = valueTime.getIntegerValue();
		else
			value = valueTime.getStringValue();

		try {
		} catch (Exception e) {
			raiseEvent(
				POINT_WRITE_EXCEPTION_EVENT,
				System.currentTimeMillis(),
				true,
				new LocalizableMessage("event.exception2", vo.getName(), e.getMessage())
			);
			e.printStackTrace();
		}
	}

	public void initialize() {
		try {
			returnToNormal(DATA_SOURCE_EXCEPTION_EVENT, System.currentTimeMillis());
		} catch (Exception e) {
			String message = e.getMessage();
			if(e.getMessage() != null && e.getMessage().contains("Unknown Error")) {
				message = "The OPC UA Server for the data source settings may not be found. ";
			}
			message = "Error while initializing data source: " +  message;
			LOG.error(message + e.getMessage(), e);
			raiseEvent(
				DATA_SOURCE_EXCEPTION_EVENT,
				System.currentTimeMillis(),
				true,
				new LocalizableMessage("event.exception2", vo.getName(), message)
			);
			return;
		}
		super.initialize();
	}

	@Override
	public void terminate() {
		super.terminate();
		try {
		} catch (Exception e) {
			String message = e.getMessage();
			if(e instanceof NullPointerException) {
				message = "The client may not have been properly initialized. ";
			}
			message = "Error while terminating data source: " +  message;
			LOG.error(message + e.getMessage(), e);
			raiseEvent(
				DATA_SOURCE_EXCEPTION_EVENT,
				System.currentTimeMillis(),
				true,
				new LocalizableMessage("event.exception2", vo.getName(), message)
			);
		}
	}
}

