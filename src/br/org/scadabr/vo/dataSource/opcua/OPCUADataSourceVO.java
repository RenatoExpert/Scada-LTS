package br.org.scadabr.vo.dataSource.opcua;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.List;
import java.util.Map;

import br.org.scadabr.rt.dataSource.opcua.OPCUADataSource;

import com.serotonin.json.JsonException;
import com.serotonin.json.JsonObject;
import com.serotonin.json.JsonReader;
import com.serotonin.json.JsonRemoteEntity;
import com.serotonin.json.JsonRemoteProperty;
import com.serotonin.mango.Common;
import com.serotonin.mango.rt.dataSource.DataSourceRT;
import com.serotonin.mango.rt.event.type.AuditEventType;
import com.serotonin.mango.util.ExportCodes;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import com.serotonin.mango.vo.dataSource.PointLocatorVO;
import com.serotonin.mango.vo.event.EventTypeVO;
import com.serotonin.util.StringUtils;
import com.serotonin.web.dwr.DwrResponseI18n;
import com.serotonin.web.i18n.LocalizableMessage;

@JsonRemoteEntity
public class OPCUADataSourceVO<T extends OPCUADataSourceVO<?>> extends DataSourceVO<T> {

	public static final Type TYPE = Type.OPCUA;

	@Override
	protected void addEventTypes(List<EventTypeVO> eventTypes) {
		eventTypes.add(
			createEventType(
				OPCUADataSource.POINT_READ_EXCEPTION_EVENT,
				new LocalizableMessage("event.ds.pointRead")
			)
		);
		eventTypes.add(
			createEventType(
				OPCUADataSource.DATA_SOURCE_EXCEPTION_EVENT,
				new LocalizableMessage("event.ds.dataSource")
			)
		);
		eventTypes.add(
			createEventType(
				OPCUADataSource.POINT_WRITE_EXCEPTION_EVENT,
				new LocalizableMessage("event.ds.dataSource")
			)
		);
	}

	private static final ExportCodes EVENT_CODES = new ExportCodes();
	static {
		EVENT_CODES.addElement(OPCUADataSource.DATA_SOURCE_EXCEPTION_EVENT, "DATA_SOURCE_EXCEPTION");
		EVENT_CODES.addElement(OPCUADataSource.POINT_READ_EXCEPTION_EVENT, "POINT_READ_EXCEPTION");
		EVENT_CODES.addElement(OPCUADataSource.POINT_WRITE_EXCEPTION_EVENT, "POINT_WRITE_EXCEPTION");
	}

	@Override
	public DataSourceRT createDataSourceRT() {
		return new OPCUADataSource(this);
	}

	@Override
	public PointLocatorVO createPointLocator() {
		return new OPCUAPointLocatorVO();
	}

	@Override
	public LocalizableMessage getConnectionDescription() {
		return new LocalizableMessage("common.default", this.endpoint);
	}

	@Override
	public ExportCodes getEventCodes() {
		return EVENT_CODES;
	}

	@Override
	public com.serotonin.mango.vo.dataSource.DataSourceVO.Type getType() {
		return TYPE;
	}

	@JsonRemoteProperty
	private String endpoint = "opc.tcp://localhost:4840/";
	@JsonRemoteProperty
	private String user = "";
	@JsonRemoteProperty
	private String password = "";

	public String getEndpoint() {
		return endpoint;
	}

	public void setEndpoint(String endpoint) {
		this.endpoint = endpoint;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	@Override
	public void validate(DwrResponseI18n response) {
		super.validate(response);
		/*
		if (StringUtils.isEmpty(endpoint))
			response.addContextualMessage("endpoint", "validate.required");
		if (StringUtils.isEmpty(user))
			response.addContextualMessage("user", "validate.required");
		if (StringUtils.isEmpty(password))
			response.addContextualMessage("password", "validate.required");
		if (updatePeriods <= 0)
			response.addContextualMessage("updatePeriods", "validate.greaterThanZero");
		*/
	}

	@Override
	protected void addPropertiesImpl(List<LocalizableMessage> list) {
		AuditEventType.addPropertyMessage(list, "dsEdit.opcua.endpoint", endpoint);
		AuditEventType.addPropertyMessage(list, "dsEdit.opcua.user", user);
		AuditEventType.addPropertyMessage(list, "dsEdit.opcua.password", password);
	}

	@Override
	protected void addPropertyChangesImpl(List<LocalizableMessage> list, T from) {
		AuditEventType.maybeAddPropertyChangeMessage(
			list,
			"dsEdit.opcua.endpoint",
			from.getEndpoint(),
			endpoint
		);
		AuditEventType.maybeAddPropertyChangeMessage(
			list,
			"dsEdit.opcua.user",
			from.getUser(),
			user
		);
		AuditEventType.maybeAddPropertyChangeMessage(
			list,
			"dsEdit.opcua.password",
			from.getPassword(),
			password
		);
	}
}

