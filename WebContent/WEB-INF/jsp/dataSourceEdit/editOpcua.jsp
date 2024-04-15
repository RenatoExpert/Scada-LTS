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
</script>

<div id="addDiv" class="borderDiv marB marR">
	<table>
		<tr>
			<td colspan="2" class="smallTitle">
				<fmt:message key="dsEdit.opcua.addTags" />
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<fmt:message key="dsEdit.opcua.tagName" />
				<input id="tagName" type="text" />
				<input id="btnAddTag" type="button" value="<fmt:message key="dsEdit.opcua.validateTag"/>" onclick="validateTag();" />
			</td>
		</tr>
		<tr>
			<td colspan="2" id="tagsMessage" class="formError"></td>
		</tr>
		<tr>
			<td>
				<table cellspacing="1" cellpadding="0" border="0">
					<thead class="rowHeader">
						<td align="center"><fmt:message key="dsEdit.opcua.tag" /></td>
						<td align="center"><fmt:message key="dsEdit.pointDataType" /></td>
						<td align="center"><fmt:message key="dsEdit.settable" /></td>
						<td align="center"><fmt:message key="dsEdit.opcua.validation" /></td>
						<td align="center"><fmt:message key="common.add" /></td>
					</thead>
					<!-- TODO why is the height being enforced? -->
					<tbody id="addTagsTable" style="height: 160px; overflow: auto;"></tbody>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input id="btnAddTag" type="button"
				value="<fmt:message key='dsEdit.opcua.addTags'/>"
				onclick="btnAddTag();"
			/>
			</td>
		</tr>
	</table>
</div>

<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsFoot.jspf"%>

<tag:pointList pointHelpId="opcuaPP"></tag:pointList>

