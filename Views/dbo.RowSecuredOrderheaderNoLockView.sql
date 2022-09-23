SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[RowSecuredOrderheaderNoLockView] AS
	SELECT	oh.*,
			rssrv.rowsec_rsrv_id as RowSecurity_NullUnsecured_IDSecured,
			rsu.IsUnsecured as RowSecurity_1Unsecured_NullSecured
	FROM	orderheader oh WITH (NOLOCK) 
			LEFT OUTER JOIN dbo.RowSecurity_SecuredRowValues_fn_NET('orderheader', null) rssrv ON (oh.rowsec_rsrv_id = rssrv.rowsec_rsrv_id)
			LEFT OUTER JOIN dbo.RowSecurity_Unsecured_fn_NET('orderheader', null) rsu ON (rsu.IsUnsecured = 1)
	WHERE   (rssrv.rowsec_rsrv_id > 0 or rsu.IsUnsecured = 1)

GO
GRANT DELETE ON  [dbo].[RowSecuredOrderheaderNoLockView] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecuredOrderheaderNoLockView] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecuredOrderheaderNoLockView] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecuredOrderheaderNoLockView] TO [public]
GO
