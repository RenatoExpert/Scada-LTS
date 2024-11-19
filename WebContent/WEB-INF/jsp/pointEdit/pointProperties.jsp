<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.DataTypes"%>

<script type="text/javascript">
	dojo.addOnLoad(function() {
		if (dataTypeId == <%= DataTypes.NUMERIC %>)
			show("engineeringUnitsSection");
	});
</script>

<div class="right-box my-3">
	<table class="w-100 m-3">
		<tr>
			<td colspan="3">
				<i class="bi bi-pencil-square align-middle ms-3 fs-6"></i>
				<span class="smallTitle m-3">
					<fmt:message key="pointEdit.props.props"/>
				</span>
				<tag:help id="dataPointEditing"/>
				<a href="data_point_details.shtm?dpid=${form.id}">
					<i class="bi bi-search align-middle ms-3 fs-6" title="<fmt:message key='pointEdit.props.details'/>"></i>
				</a>
			</td>
		</tr>

		<tr>
			<td class="formLabelRequired align-middle my-2">
				<fmt:message key="pointEdit.props.ds"/>
			</td>
			<td colspan="2" class="formLabelRequired align-middle my-2">
				${dataSource.name}
				<a href="data_source_edit.shtm?dsid=${dataSource.id}&pid=${form.id}">
					<i class="bi bi-database-fill-gear align-middle ms-3 fs-6" title="<fmt:message key='pointEdit.props.editDs'/>"></i>
				</a>
			</td>
		</tr>

		<spring:bind path="form.name">
			<tr>
				<td class="formLabelRequired align-middle my-2">
					<fmt:message key="pointEdit.props.name"/>
				</td>
				<td class="formField">
					<input class="w-75 form-control form-control-sm my-2" type="text" name="name" value="${status.value}"/>
				</td>
				<c:if test="${error.name != null}">
					<td class="formError">
						<fmt:message key="${error.name}"/>
					</td>
				</c:if>
			</tr>
		</spring:bind>

		<spring:bind path="form.description">
			<tr>
				<td class="formLabelRequired align-middle my-2">
					<fmt:message key="pointEdit.props.description"/>
				</td>
				<td class="formField">
					<input class="w-75 form-control form-control-sm my-2" type="text" class="formLong" name="description" value="${status.value}"/>
				</td>
				<c:if test="${error.description != null}">
					<td class="formError">
						<fmt:message key="${error.description}"/>
					</td>
				</c:if>
			</tr>
		</spring:bind>

		<tbody id="engineeringUnitsSection" style="display:none;">
			<spring:bind path="form.engineeringUnits">
				<tr>
					<td class="formLabelRequired align-middle my-2">
						<fmt:message key="pointEdit.props.engineeringUnits"/>
					</td>
					<td class="formField">
						<sst:select id="engineeringUnits" name="engineeringUnits" value="${status.value}">
							<tag:engineeringUnits/>
						</sst:select>
					</td>
					<c:if test="${error.engineeringUnits != null}">
						<td class="formError">
							<fmt:message key="${error.engineeringUnits}"/>
						</td>
					</c:if>
				</tr>
			</spring:bind>
		</tbody>

	</table>
</div>

