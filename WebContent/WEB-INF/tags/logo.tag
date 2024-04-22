<%@include file="/WEB-INF/tags/decl.tagf" %>

<div class="logo-section">
	<div class="logo-section--title">
		<img id="logo" src="assets/logo.png" alt="Logo">
		<c:if test="${(!empty scadaVersion) && scadaVersion.isShowVersionInfo()}">
			<c:if test="${!empty scadaVersion.getCompanyName()}">
				<div id="company-container">
					<span>
						<fmt:message key="logo.for"/>
					</span>
					<span id="company-name">
						${scadaVersion.getCompanyName()}
					</span>
				</div>
			</c:if>
		</c:if>
	</div>
</div>

