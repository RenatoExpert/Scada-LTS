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
<tag:page dwr="DataSourceListDwr" onload="init">
  <script>
    function init() {
        DataSourceListDwr.init(function(response) {
            if (response.data.types) {
                dwr.util.addOptions("dataSourceTypes", response.data.types, "key", "value");
                show("dataSourceTypesContent");
            }
        });
    }
    
    function updateStateDescription(idDs, description) {
        var idStateDesc = "stateDes"+idDs;
        jQuery("#"+idStateDesc).html(description);
    }

    function toggleDataSource(dataSourceId) {
        var imgNode = $("dsImg"+ dataSourceId);
        if (!hasImageFader(imgNode)) {
            DataSourceListDwr.toggleDataSource(dataSourceId, function(result) {
                updateStatusImg($("dsImg"+ result.id), result.enabled, true);
                updateStateDescription(result.id, result.state);
            });
            startImageFader(imgNode);
        }
    }

    function toggleDataPoint(dataPointId) {
        var imgNode = $("dpImg"+ dataPointId);
        if (!hasImageFader(imgNode)) {
            DataSourceListDwr.toggleDataPoint(dataPointId, function(result) {
                updateStatusImg($("dpImg"+ result.data.id), result.data.enabled, false);
            });
            startImageFader(imgNode);
        }
    }
    
    function updateStatusImg(imgNode, enabled, ds) {
        stopImageFader(imgNode);
        if (ds)
            setDataSourceStatusImg(enabled, imgNode);
        else
            setDataPointStatusImg(enabled, imgNode);
    }
    
    function deleteDataSource(dataSourceId) {
        if (confirm("<fmt:message key="dsList.dsDeleteConfirm"/>")) {
            startImageFader("deleteDataSourceImg"+ dataSourceId);
            DataSourceListDwr.deleteDataSource(dataSourceId, function(dataSourceId) {
                stopImageFader("deleteDataSourceImg"+ dataSourceId);
                // Delete the data source rowTable
                var rowTable = $("dataSourceRow"+ dataSourceId);
                rowTable.parentNode.removeChild(rowTable);
                // Delete the points section.
                rowTable = $("points"+ dataSourceId);
                rowTable.parentNode.removeChild(rowTable);
            });
        }
    }
    
    function copyDataSource(fromDataSourceId) {
        startImageFader("copyDataSourceImg"+ fromDataSourceId);
        DataSourceListDwr.copyDataSource(fromDataSourceId, function(toDataSourceId) {
            window.location = "data_source_edit.shtm?dsid="+ toDataSourceId;
        });
    }
    
    function deleteDataPoint(pointId) {
        if (confirm("<fmt:message key="dsList.pointDeleteConfirm"/>")) {
            DataSourceListDwr.deleteDataPoint(pointId, function(pointId) {
                var rowTable = $("pointRow"+ pointId);
                rowTable.parentNode.removeChild(rowTable);
            });
        }
    }
    
    function addDataSource() {
        window.location = "data_source_edit.shtm?typeId="+ $get("dataSourceTypes");
    }
  </script>
  
  <table class="subPageHeader">
    <tr>
      <td>
        <i class="bi bi-database-add" title="<fmt:message key='dsList.dataSources'/>"></i>
        <span class="smallTitle"><fmt:message key="dsList.dataSources"/></span>
        <tag:help id="dataSourceList"/>
      </td>
      <td align="right" id="dataSourceTypesContent" style="display:none">
        <select id="dataSourceTypes"></select>
        <i class="bi bi-database-fill-add text-success" title="<fmt:message key='common.add'/>" onclick="addDataSource()" style="cursor: pointer;"></i>
      </td>
    </tr>
    
    
    <tr>
      <td colspan="2">
        <table class="dataSourcesTable" >
          <tr>
            <td colspan="2">
              <table class="dataSourcesTable">
                <tr class="rowHeader">
                  <td><fmt:message key="dsList.name"/></td>
                  <td><fmt:message key="dsList.type"/></td>
                  <td><fmt:message key="dsList.connection"/></td>
                  <td><fmt:message key="dsList.status"/></td>
                  <td><fmt:message key="dsList.statusDescribe"/></td>
                  <td></td>
                </tr>
                <c:set var="hideText"><fmt:message key="dsList.hide"/></c:set>
                <c:set var="showText"><fmt:message key="dsList.show"/></c:set>
                <c:forEach items="${data}" var="listParent"> 
                    <tr class="rowTable" id="dataSourceRow${listParent.parent.id}">
                    <td><b>${listParent.parent.name}</b></td>
                    <td><fmt:message key="${listParent.parent.type.key}"/></td>
                    <td><sst:i18n message="${listParent.parent.connectionDescription}"/></td>
                    <td align="center">
                    <c:choose>
                        <c:when test="${listParent.parent.enabled}">
                            <a href="#" title="<fmt:message key='common.enabledToggle'/>" 
                            id="dsImg${listParent.parent.id}" onclick="toggleDataSource(${listParent.parent.id})" class="bi bi-database-fill-check text-success">
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="#" title="<fmt:message key='common.disabledToggle'/>" 
                            id="dsImg${listParent.parent.id}" onclick="toggleDataSource(${listParent.parent.id})"  class="bi bi-database-fill-x  text-danger">
                            </a>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    <td id="stateDes${listParent.parent.id}">
                      ${listParent.parent.state.describe}
                    </td>
                    <td>
                      <a href="data_source_edit.shtm?dsid=${listParent.parent.id}" title="<fmt:message key='common.edit'/>">
                          <i class="bi bi-pencil-square"></i>
                      </a>
                      <a href="#" title="<fmt:message key='dsList.show'/>" onclick="togglePanelVisibility2(this, 'points${listParent.parent.id}', '${hideText}', '${showText}');">
                          <i class="bi bi-database-fill-gear"></i>
                      </a>
                        <a href="#" title="<fmt:message key='common.delete'/>" id="deleteDataSourceImg${listParent.parent.id}" onclick="deleteDataSource(${listParent.parent.id})">
                            <i class="bi bi-database-dash text-danger"></i>
                        </a>
                        <a href="#" title="<fmt:message key='common.copy'/>" id="copyDataSourceImg${listParent.parent.id}" onclick="copyDataSource(${listParent.parent.id})">
                             <i class="bi bi-database-add text-success"></i>
                        </a>
                    </td>
                  </tr>
                  
                  <tr id="points${listParent.parent.id}" class="rowAlt2" style="display:none">
                    <td colspan="5" class="datasource-row">
                      <table cellspacing="1" cellpadding="0" border="0">
                        <tr class="rowHeader">
                          <td><fmt:message key="dsList.pointName"/></td>
                          <td><fmt:message key="dsList.description"/></td>
                          <td><fmt:message key="dsList.status"/></td>
                          <td></td>
                        </tr>
                        <c:forEach items="${listParent.list}" var="point">
                          <tr id="pointRow${point.id}">
                            <td>${point.name}</td>
                            <td><sst:i18n message="${point.dataTypeMessage}"/> / <sst:i18n message="${point.configurationDescription}"/></td>
                            <td align="center">
                              <c:choose>
                                <c:when test="${point.enabled}">
                                    <a href="#" title="<fmt:message key='common.enabledToggle'/>" 
                                    id="dpImg${point.id}" onclick="toggleDataPoint(${point.id})"  class="bi bi-puzzle-fill text-success">
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="#" title="<fmt:message key='common.disabledToggle'/>" 
                                    id="dpImg${point.id}" onclick="toggleDataPoint(${point.id})" class="bi bi-puzzle-fill text-danger">
                                    </a>
                                </c:otherwise>
                              </c:choose>
                            </td>
                            <td>
                                <a href="data_point_details.shtm?dpid=${point.id}" title="<fmt:message key='events.pointDetails'/>">
                                    <i class="bi bi-search"></i>
                                </a>
                            </td>
                            <td>
                                <a href="data_point_edit.shtm?dpid=${point.id}" title="<fmt:message key='pointEdit.props.props'/>">
                                    <i class="bi bi-pencil-square"></i>
                                </a>
                            </td>
                        </c:forEach>
                      </table>
                    </td>
                  </tr>
                </c:forEach> 
              </table>
            </td>
          </tr>
        </table>  
      </td>
    </tr>
    <%-- <tag:newPageNotification href="./app.shtm#/datasources" ref="datasourcesNotification"/> --%>
  </table>
</tag:page>