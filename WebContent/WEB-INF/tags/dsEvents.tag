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
--%><%@include file="/WEB-INF/tags/decl.tagf"%><%--
--%><%@tag body-content="empty"%><%--
--%><table width="100%">
<tr><td class="m-4 w-100" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
  <tr><td class="smallTitle">
    <i class="bi bi-flag align-middle ms-3 fs-5"></i>
    <fmt:message key="dsEdit.events.alarmLevels"/>
  </td></tr>
</table>
<table cellspacing="1" class="m-3">
  <c:choose>
    <c:when test="${empty dataSource.eventTypes}">
      <tr><td><b><fmt:message key="dsEdit.events.noEvents"/></b></td></tr>
    </c:when>
    <c:otherwise>
      <c:forEach items="${dataSource.eventTypes}" var="type">
        <tr>
          <td><b><sst:i18n message="${type.description}"/></b></td>
          <td class="d-flex align-items-center justify-content-center">
            <sst:select id="alarmLevel${type.typeRef2}" onchange="alarmLevelChanged(${type.typeRef2})" value="${type.alarmLevel}">
              <tag:alarmLevelOptions sst="true"/>
            </sst:select>
            <i id="alarmLevelImg${type.typeRef2}" class="bi bi-flag-fill align-middle ms-3 fs-5" style="display:none;"></i>
            <script type="text/javascript">setAlarmLevelImg(${type.alarmLevel}, 'alarmLevelImg${type.typeRef2}')</script>
          </td>
        </tr>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</table>