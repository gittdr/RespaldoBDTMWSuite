SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vista_estancias_parte1]

as

SELECT pd.pyt_itemcode, pt.pyt_description, pd.asgn_id, pd.ord_hdrnumber, pd.mov_number, pd.pyd_description, pd.pyd_amount, pd.pyd_createdon, pd.pyh_payperiod, 
                  DATEPART(month, pd.pyh_payperiod) AS mespago, DATEPART(week, pd.pyh_payperiod) AS semanapago, DATEPART(day, pd.pyh_payperiod) AS diapago, 
                  DATEPART(month, pd.pyd_createdon) AS mescrea, DATEPART(week, pd.pyd_createdon) AS semanacrea, DATEPART(day, pd.pyd_createdon) AS diacre, pd.pyd_authcode, 
                  pd.pyd_createdby, pd.pyd_status, DATEDIFF(day, pd.pyd_createdon, pd.pyh_payperiod) AS difdias, dbo.legheader.lgh_tractor AS tractor, 
                   (select name from labelfile where abbr = dbo.legheader.lgh_class3 and labeldefinition = 'Revtype3' ) AS proyecto, dbo.ttsusers.usr_fname, dbo.ttsusers.usr_lname, CASE LEFT(pt.pyt_description, 1) 
                  WHEN '%' THEN 'Comprobacion' ELSE 'Anticipo' END AS Expr1, pd.pyd_remarks
FROM     dbo.paydetail (nolock) AS pd INNER JOIN
                  dbo.paytype (nolock) AS pt ON pd.pyt_itemcode = pt.pyt_itemcode INNER JOIN
                  dbo.legheader (nolock)  ON pd.lgh_number = dbo.legheader.lgh_number LEFT OUTER JOIN
                  dbo.ttsusers (nolock)  ON pd.pyd_createdby = dbo.ttsusers.usr_userid
WHERE  (pd.pyt_itemcode in ('COMEST', 'COBEST', 'ECC')) AND (pd.pyd_createdon > '01-01-2015') 


GO
