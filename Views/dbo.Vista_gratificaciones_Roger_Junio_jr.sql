SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[Vista_gratificaciones_Roger_Junio_jr]
AS
SELECT        TOP (100) PERCENT COUNT(*) AS veces, SUM(pd.pyd_amount) AS monto,  dbo.orderheader.ord_tractor as Tractor, Codigos_comprobacion.descripcion, pd.pyd_description,DATEPART(year, pd.pyd_createdon) AS añocrea, DATEPART(month, pd.pyd_createdon) AS mescrea, 
                         dbo.orderheader.ord_hdrnumber AS NoOrden, dbo.orderheader.ord_completiondate AS fechaorden, pd.asgn_id AS Operador,
                             (SELECT        SUM(lgh_miles) AS Expr1
                               FROM            dbo.legheader
                           WHERE        (ord_hdrnumber = dbo.orderheader.ord_hdrnumber)) AS Kms,
                             (SELECT        name
                               FROM            dbo.labelfile
                               WHERE        (labeldefinition = 'RevType3') AND (abbr = dbo.orderheader.ord_revtype3)) AS proyOrden
							   ,Codigos_comprobacion.[TipoAtribucion],pd.pyd_createdon 
							   ,(Select [proyecto] from [dbo].[TractorProyHistory] tph where tph.[trc_number] = dbo.orderheader.ord_tractor and tph.[fecha] = cast(pd.pyd_createdon as date)) as proye,
							    pd.pyh_payperiod as fechapago,
							   orderheader.ord_revtype4 as EC
FROM            dbo.paydetail AS pd WITH (nolock) 
						 INNER JOIN dbo.Codigos_comprobacion AS Codigos_comprobacion ON ISNULL(pd.pyd_tprsplit_number, 50) = Codigos_comprobacion.id_codigo 
						 LEFT OUTER JOIN dbo.paytype AS pt WITH (nolock) ON pd.pyt_itemcode = pt.pyt_itemcode 
						 INNER JOIN dbo.orderheader ON pd.mov_number = dbo.orderheader.mov_number
WHERE        (pd.pyt_itemcode IN ('COMGRA')) AND (pd.pyd_createdon > '01-01-2020') AND (pd.asgn_id <> 'PROVEEDO') AND (pd.pyd_createdby <> 'sa')
GROUP BY DATEPART(year, pd.pyd_createdon), DATEPART(month, pd.pyd_createdon),  dbo.orderheader.ord_tractor,Codigos_comprobacion.descripcion,pd.pyd_description ,dbo.orderheader.ord_revtype3, dbo.orderheader.ord_hdrnumber, pd.asgn_id, 
                         dbo.orderheader.ord_completiondate,Codigos_comprobacion.[TipoAtribucion],pd.pyd_createdon ,
						 pd.pyh_payperiod ,
							   orderheader.ord_revtype4 
						 ORDER BY añocrea desc, mescrea desc

GO
