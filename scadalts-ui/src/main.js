import 'bootstrap/dist/css/bootstrap.min.css';

import { createApp } from 'vue';
import App from './apps/App.vue';
import router from './router/index';
import store from './store';

import VueCookie from 'vue-cookie';
import VueLogger from 'vuejs-logger';
import VueDayjs from 'vue-dayjs-plugin';

import IsAlive from '@/components/graphical_views/IsAlive.vue';
import Watchdog from '@/components/graphical_views/watchdog/index.vue';
import CMP from '@/components/graphical_views/cmp/CMP.vue';
import AutoManual from '@/components/graphical_views/cmp2/AutoManual.vue'
import AutoManual3 from '@/components/graphical_views/cmp3/AutoManual3.vue'
import SimpleComponentSVG from '@/components/graphical_views/SimpleComponentSVG.vue';
import ExportImportPointHierarchy from '@/components/point_hierarchy/ExportImportPointHierarchy.vue';
import SleepAndReactivationDS from '@/components/forms/SleepAndReactivationDS.vue';
import VueLodash from 'vue-lodash';

import LineChartComponent from '@/components/amcharts/LineChartComponent.vue';
import RangeChartComponent from '@/components/amcharts/RangeChartComponent.vue';
import TableComponent from '@/components/graphical_views/pointTables/SimplePointTable.vue'

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
	faCoffee,
	faTimes,
	faBars,
	faBell,
	faFileMedicalAlt,
	faInfo,
	faListAlt,
	faCogs,
} from '@fortawesome/free-solid-svg-icons';
import i18n from './i18n';
import LiveAlarms from '@/components/graphical_views/AlarmsComponent.vue';
import RefreshView from '@/components/graphical_views/RefreshView.vue';
import SMSDomain from '@/components/forms/SMSDomain.vue';
import vuetify from './plugins/vuetify';
import 'roboto-fontface/css/roboto/roboto-fontface.css';
import '@mdi/font/css/materialdesignicons.css';
import * as uiv from 'uiv';
import svgJS from './plugins/svg';

library.add(
	faCoffee,
	faTimes,
	faBars,
	faBell,
	faFileMedicalAlt,
	faInfo,
	faListAlt,
	faCogs
);

createApp.component('font-awesome-icon', FontAwesomeIcon);

const isProduction = process.env.NODE_ENV === 'production';

const options = {
	isEnabled: true,
	logLevel: isProduction ? 'error' : 'debug',
	stringifyArguments: false,
	showLogLevel: true,
	showMethodName: true,
	separator: '|',
	showConsoleColors: true,
};

createApp.use(VueLogger, options);

const optionsLodash = { name: 'lodash' };

createApp.use(VueLodash, optionsLodash);

createApp.use(VueCookie);
createApp.use(VueDayjs);

createApp.use(svgJS);

createApp.config.devtools = true;

createApp({
	router,
	store,
	i18n,
	vuetify,
	render: (h) => h(App),
}).$mount('#app');

createApp.use(uiv);

if (window.document.getElementById('app-isalive') != undefined) {
	const isAliveDom = document.getElementById('app-isalive');
	new createApp({
		store,
		render: (h) =>
			h(IsAlive, {
				props: {
					plabel: isAliveDom.getAttribute('plabel'),
					ptimeWarning: isAliveDom.getAttribute('ptime-warning'),
					ptimeError: isAliveDom.getAttribute('ptime-error'),
					ptimeRefresh: isAliveDom.getAttribute('ptime-refresh'),
					pTextWarning: isAliveDom.getAttribute('ptext-warning'),
					feedbackUrl: isAliveDom.getAttribute('feedback-url'),
				},
			}),
	}).$mount('#app-isalive');
}

const watchdogId = "app-isalive2";
if (!!window.document.getElementById(watchdogId)) {
	const watchdogEl = document.getElementById(watchdogId);
	new createApp({
		store,
		i18n,
		vuetify,
		render: (h) =>
			h(Watchdog, {
				props: {
					name: watchdogEl.getAttribute('name'),
					interval: watchdogEl.getAttribute('interval') !== null ? Number(watchdogEl.getAttribute('interval')) : 10000,
					wdHost: watchdogEl.getAttribute('wd-host'),
					wdPort: watchdogEl.getAttribute('wd-port') !== null ? Number(watchdogEl.getAttribute('wd-port')) : null,
					wdMessage: watchdogEl.getAttribute('wd-message'),
					dpValidation: watchdogEl.getAttribute('dp-validation') !== null ? JSON.parse(watchdogEl.getAttribute('dp-validation')) : null,
					dpBreak: watchdogEl.getAttribute('dp-break') !== null,
					dpWarnAsFail: watchdogEl.getAttribute('dp-warn-as-fail') !== null,
				},
			}),
	}).$mount(`#${watchdogId}`);
}

for (let i = 0; i < 20; i++) {
	const cmpId = `app-cmp-${i}`;
	if (window.document.getElementById(cmpId) != undefined) {
		new createApp({
			vuetify,
			render: (h) =>
				h(CMP, {
					store,
					props: {
						pLabel: window.document.getElementById(cmpId).getAttribute('plabel'),
						pTimeRefresh: window.document
							.getElementById(cmpId)
							.getAttribute('ptimeRefresh'),
						pConfig: window.document.getElementById(cmpId).getAttribute('pconfig'),
						pxIdViewAndIdCmp: window.document
							.getElementById(cmpId)
							.getAttribute('pxIdViewAndIdCmp'),
					},
				}),
		}).$mount('#' + cmpId);
	}
}

for (let i = 0; i < 10; i++) {
	const cmpId = `app-cmp2-${i}`;
	const el = window.document.getElementById(cmpId);
	if (el != undefined) {
		new createApp({
			store,
			i18n,
			vuetify,
			render: (h) =>
				h(AutoManual, {
					props: {
						pConfig: JSON.parse(el.getAttribute('pconfig')),
						pLabel: el.getAttribute('plabel'),
						pTimeRefresh: el.getAttribute('ptimeRefresh') !== null ? el.getAttribute('ptimeRefresh') : 10000,
						pxIdViewAndIdCmp: el.getAttribute('pxIdViewAndIdCmp'),
						pZeroState: el.getAttribute('pzeroState') !== null ? el.getAttribute('pzeroState') : 'Auto',
						pWidth: el.getAttribute('pwidth') !== null ? el.getAttribute('pwidth') : 140,
						pRequestTimeout: el.getAttribute('prequestTimeout') !== null ? el.getAttribute('prequestTimeout') : 5000,
						pHideControls: el.getAttribute('phideControls') !== null,
						pDebugRequest: el.getAttribute('pdebugRequest') !== null,
					},
				})
		}).$mount('#' + cmpId);
	}
}

for (let i = 0; i < 10; i++) {
	const cmpId = `app-cmp3-${i}`;
	const el = window.document.getElementById(cmpId);
	if (el != undefined) {
		new createApp({
			store,
			i18n,
			vuetify,
			render: (h) =>
				h(AutoManual3, {
					props: {
						pConfig: JSON.parse(el.getAttribute('pconfig')),
						pLabel: el.getAttribute('plabel'),
						pTimeRefresh: el.getAttribute('ptimeRefresh') !== null ? el.getAttribute('ptimeRefresh') : 10000,
						pxIdViewAndIdCmp: el.getAttribute('pxIdViewAndIdCmp'),
						pZeroState: el.getAttribute('pzeroState') !== null ? el.getAttribute('pzeroState') : 'Auto',
						pWidth: el.getAttribute('pwidth') !== null ? el.getAttribute('pwidth') : 140,
						pRequestTimeout: el.getAttribute('prequestTimeout') !== null ? el.getAttribute('prequestTimeout') : 5000,
						pHideControls: el.getAttribute('phideControls') !== null,
						pDebugRequest: el.getAttribute('pdebugRequest') !== null,
					},
				})
		}).$mount('#' + cmpId);
	}
}




if (window.document.getElementById('simple-component-svg') != undefined) {
	new createApp({
		render: (h) =>
			h(SimpleComponentSVG, {
				props: {
					pxidPoint: window.document
						.getElementById('simple-component-svg')
						.getAttribute('pxidPoint'),
					ptimeRefresh: window.document
						.getElementById('simple-component-svg')
						.getAttribute('ptimeRefresh'),
					plabel: window.document
						.getElementById('simple-component-svg')
						.getAttribute('plabel'),
					pvalue: window.document
						.getElementById('simple-component-svg')
						.getAttribute('pvalue'),
				},
			}),
	}).$mount('#simple-component-svg');
}

if (window.document.getElementById('sleep-reactivation-ds') != undefined) {
	new createApp({
		render: (h) => h(SleepAndReactivationDS),
	}).$mount('#sleep-reactivation-ds');
}

if (window.document.getElementById('sms-domain') != undefined) {
	new createApp({
		vuetify,
		render: (h) => h(SMSDomain),
	}).$mount('#sms-domain');
}

if (window.document.getElementById('export-import-ph') != undefined) {
	new createApp({
		render: (h) => h(ExportImportPointHierarchy),
	}).$mount('#export-import-ph');
}

for (let x = 0; x < 10; x++) {
	const chartId = `chart-line-${x}`;
	const el = window.document.getElementById(chartId);
	if (el != undefined) {
		new createApp({
			render: (h) =>
				h(LineChartComponent, {
					props: {
						pointIds: el.getAttribute('point-ids'),
						useXid: el.getAttribute('use-xid') !== null,
						separateAxis: el.getAttribute('separate-axes') !== null,
						stepLine: el.getAttribute('step-line') !== null,
						startDate: el.getAttribute('start-date'),
						endDate: el.getAttribute('end-date'),
						refreshRate: el.getAttribute('refresh-rate'),
						width: el.getAttribute('width') !== null ? el.getAttribute('width') : '500',
						height: el.getAttribute('height') !== null ? el.getAttribute('height') : '400',
						color: el.getAttribute('color'),
						strokeWidth: Number(el.getAttribute('stroke-width')),
						aggregation: Number(el.getAttribute('aggregation')),
						showScrollbar: el.getAttribute('show-scrollbar') !== null,
						showLegend: el.getAttribute('show-legned') !== null,
						showBullets: el.getAttribute('show-bullets') !== null,
						showExportMenu: el.getAttribute('show-export-menu') !== null,
						smoothLine: Number(el.getAttribute('smooth-line')),
						serverValuesLimit: Number(el.getAttribute('server-values-limit')),
						serverLimitFactor: Number(el.getAttribute('server-limit-factor')),
						webSocketEnabled: el.getAttribute('web-socket-enabled') !== null,
						showControls: el.getAttribute('show-controls') !== null,
					},
				}),
		}).$mount(`#${chartId}`);
	}
}

for (let x = 0; x < 10; x++) {
	const chartId = `chart-range-${x}`;
	const el = window.document.getElementById(chartId);
	if (el != undefined) {
		new createApp({
			store,
			vuetify,
			render: (h) =>
				h(RangeChartComponent, {
					props: {
						chartId: x,
						pointIds: el.getAttribute('point-ids'),
						useXid: el.getAttribute('use-xid') !== null,
						separateAxis: el.getAttribute('separate-axes') !== null,
						stepLine: el.getAttribute('step-line') !== null,
						aggregation: Number(el.getAttribute('aggregation')),
						strokeWidth: Number(el.getAttribute('stroke-width')),
						showBullets: el.getAttribute('show-bullets') !== null,
						showExportMenu: el.getAttribute('show-export-menu') !== null,
						smoothLine: Number(el.getAttribute('smooth-line')),
						width: el.getAttribute('width') !== null ? el.getAttribute('width') : '500',
						height: el.getAttribute('height') !== null ? el.getAttribute('height') : '400',
						color: el.getAttribute('color'),
						serverValuesLimit: Number(el.getAttribute('server-values-limit')),
						serverLimitFactor: Number(el.getAttribute('server-limit-factor')),
					},
				}),
		}).$mount(`#${chartId}`);
	}
}

for (let x = 0; x < 10; x++) {
	const baseId = `simple-table-${x}`;
	const el = window.document.getElementById(baseId);
	if (el != undefined) {
		createApp({
			store,
			vuetify,
			render: (h) =>
				h(TableComponent, {
					props: {
						pointIds: el.getAttribute('point-ids'),
						startDate: el.getAttribute('start-date'),
						showTotal: el.getAttribute('total') !== null,
						showAverage: el.getAttribute('average') !== null,
						showMax: el.getAttribute('max') !== null,
						showMin: el.getAttribute('min') !== null,
						roundValue: Number(el.getAttribute('round')),
						maxWidth: el.getAttribute('width' !== null ? Number(el.getAttribute('width')) : 600 ),
						maxHeight: el.getAttribute('height' !== null ? Number(el.getAttribute('height')) : 400 ),
					},
				}),
		}).$mount(`#${baseId}`);
	}
}

if (window.document.getElementById('refresh-view') != undefined) {
	createApp({
		store,
		render: (h) =>
			h(RefreshView, {
				props: {
					ptimeToCheckRefresh: window.document
						.getElementById('refresh-view')
						.getAttribute('ptimeToCheckRefresh'),
					pviewId: window.document.getElementById('refresh-view').getAttribute('pviewId'),
				},
			}),
	}).$mount('#refresh-view');
}

if (window.document.getElementById('live-alarms') != undefined) {
	console.log(
		`test+ ${window.document
			.getElementById('live-alarms')
			.getAttribute('show-acknowledge-btn')}`
	);

	createApp({
		store,
		vuetify,
		render: (h) =>
			h(LiveAlarms, {
				props: {
					pShowAcknowledgeBtn: window.document
						.getElementById('live-alarms')
						.getAttribute('show-acknowledge-btn'),
					pShowMainToolbar: window.document
						.getElementById('live-alarms')
						.getAttribute('show-main-toolbar'),
					pShowSelectToAcknowledge: window.document
						.getElementById('live-alarms')
						.getAttribute('show-select-to-acknowledge'),
					pShowPagination: window.document
						.getElementById('live-alarms')
						.getAttribute('show-pagination'),
					pMaximumNumbersOfRows: window.document
						.getElementById('live-alarms')
						.getAttribute('max-number-of-rows'),
				},
			}),
	}).$mount('#live-alarms');
}
