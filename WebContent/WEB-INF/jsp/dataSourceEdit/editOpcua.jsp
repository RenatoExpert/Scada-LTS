<%@ include file="/WEB-INF/jsp/include/tech.jsp"%>
<%@page import="com.serotonin.modbus4j.code.RegisterRange"%>
<%@page import="com.serotonin.modbus4j.code.DataType"%>

<c:set var="dsDesc">
	<fmt:message key="dsEdit.opcua.desc" />
</c:set>
<c:set var="dsHelpId" value="opcuaDS" />
<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsHead.jspf"%>

<section>
	<table>
		<tr>
			<td class="formLabelRequired">
				<fmt:message key="dsEdit.opcua.endpoint" />
			</td>
			<td class="formField">
				<input id="endpoint" type="text" value="${dataSource.endpoint}" />
			</td>
		</tr>
		<tr>
			<td class="formLabelRequired">
				<fmt:message key="dsEdit.opcua.user" />
			</td>
			<td class="formField">
				<input id="user" type="text" value="${dataSource.user}" />
			</td>
		</tr>
		<tr>
			<td class="formLabelRequired">
				<fmt:message key="dsEdit.opcua.password" />
			</td>
			<td class="formField"><input id="password" type="password"
				name="password" value="${dataSource.password}" maxlength="20" />
			</td>
		</tr>
	</table>
</div>

<script>
	function saveDataSourceImpl() {
		console.log("HEY saveDataSourceImpl()");
		DataSourceEditDwr.saveOPCUADataSource(
			$get("dataSourceName"),
			$get("dataSourceXid"),
			$get("endpoint"),
			$get("user"),
			$get("password"),
			saveDataSourceCB
		);
	}

	function saveDataSourceCB(response) {
		console.log("HEY saveDataSourceCB()");
		console.log("dataSourceEdit.jsp::saveDataSourceCB - init");
		stopImageFader("dsSaveImg");
		if (response.hasMessages) {
			showDwrMessages(response.messages, "dataSourceGenericMessages");
		} else {
			showMessage("dataSourceMessage", "Data source has been saved");
			DataSourceEditDwr.getPoints(writePointList);
		}
		getAlarms();
		console.log("dataSourceEdit.jsp::saveDataSourceCB - done");
	}

	function initImpl() {
	}

	function scanImpl() {
	}

	function locatorTestImpl(locator) {
	}

	function dataTestImpl(slaveId, range, offset, length) {
	}

	function savePointImpl(locator) {
		console.log("savePointImpl() FUNCTION");
		delete locator.settable;
		delete locator.rangeMessage;
		delete locator.dataTypeId;
		delete locator.relinquishable;

		locator.tagUrl = $get("tagUrl");
		DataSourceEditDwr.saveModbusPointLocator(currentPoint.id, $get("xid"), $get("name"), locator, savePointCB);
	}

	function savePointCB() {
		console.log("savePointCB() FUNCTION");
	}
</script>

<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsFoot.jspf"%>

<tag:pointList pointHelpId="opcuaPP">
	<tr id="tagUrl">
		<td class="formLabelRequired">
			<fmt:message key="dsEdit.opcua.tagUrl"/>
		</td>
		<td class="formField">
			<input type="text" id="tagUrl"/>
		</td>
	</tr>
</tag:pointList>

