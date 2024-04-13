<%@ include file="/WEB-INF/jsp/include/tech.jsp"%>
<%@page import="com.serotonin.modbus4j.code.RegisterRange"%>
<%@page import="com.serotonin.modbus4j.code.DataType"%>

<c:set var="dsDesc">
	<fmt:message key="dsEdit.opcua.desc" />
</c:set>
<c:set var="dsHelpId" value="opcDS" />
<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsHead.jspf"%>
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
<tr>
<tr>
	<td class="formLabelRequired">
		<fmt:message key="dsEdit.updatePeriod" />
	</td>
	<td class="formField">
		<input type="text" id="updatePeriods" value="${dataSource.updatePeriods}" class="formShort" />
		<sst:select id="updatePeriodType" value="${dataSource.updatePeriodType}">
			<tag:timePeriodOptions sst="true" ms="true" s="true" min="true" h="true" />
		</sst:select>
	</td>
</tr>

<tr>
	<td class="formLabelRequired">
		<fmt:message key="dsEdit.opcua.creationMode" />
	</td>
	<td class="formField">
		<sst:select id="selectMethodTag" value="${dataSource.creationMode}" onchange="toggleDiv(this)">
			<sst:option value="AddTags">
				<fmt:message key="dsEdit.opcua.addTags" />
			</sst:option>
		</sst:select>
	</td>
</tr>

</table>
</div>
</td>

<!-- addTagsMethod -->

<td valign="top">
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
		<input id="btnAddTag" type="button" value="<fmt:message key="dsEdit.opc.addTags"/>" onclick="btnAddTag();" />
	</td>
</tr>

<%@ include file="/WEB-INF/jsp/dataSourceEdit/dsFoot.jspf"%>

<tag:pointList pointHelpId="opcuaPP"></tag:pointList>
