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
--%><%@include file="/WEB-INF/tags/decl.tagf" %><%--
--%><%@tag body-content="empty" %><%--
--%><%@attribute name="event" type="com.serotonin.mango.rt.event.EventInstance" required="true" rtexprvalue="true" %><%--
--%><c:if test="${event.userNotified}">
  <c:choose>
    <c:when test="${event.acknowledged}">
        <a href="#" class="nav-link" title="<fmt:message key='events.acknowledged'/>" style="display: inline-block;">
            <i class="bi bi-check-circle-fill text-success ms-1 me-1"></i>
        </a>
    </c:when>
    <c:otherwise>
      <c:if test="${not event.active}">
          <a href="#" id="ackImg${event.id}" class="nav-link" onclick="ackEvent(${event.id})" title="<fmt:message key='events.acknowledge'/>" style="display: inline-block;">
              <i class="bi bi-check text-blue-add ms-1 me-1"></i>
          </a>
      </c:if>
      <c:choose>
        <c:when test="${event.silenced}">
          <a href="#" id="silenceImg${event.id}" class="nav-link" onclick="toggleSilence(${event.id})" title="<fmt:message key='events.unsilence'/>" style="display: inline-block;">
              <i class="bi bi-volume-mute text-blue-add ms-1 me-1"></i>
          </a>
        </c:when>
        <c:otherwise>
          <a href="#" id="silenceImg${event.id}" class="nav-link" onclick="toggleSilence(${event.id})" title="<fmt:message key='events.silence'/>" style="display: inline-block;">
              <i class="bi bi-volume-up text-danger ms-1 me-1"></i>
          </a>
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>