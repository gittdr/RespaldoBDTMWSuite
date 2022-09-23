SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



























CREATE VIEW [dbo].[VISTA_Fe_detail]
AS

/* ******************************************************* */
/* Vista modificada Vista_Fe_Detail                        */
/*                                                         */
/* Se modificaron los campos "descripcion" de ambas con-   */
/* sultas, con el fin de eliminar los bloques de when que  */
/* la vista tenía con anterioridad, y hacer la vista más   */
/* fácil de mantener.                                      */
/* ******************************************************* */
/*   ----EDBM----                24/05/2013 15:40          */
/* ******************************************************* */
  

/* ******************************************************* */
/* Vista modificada Vista_Fe_Detail                        */
/*                                                         */
/* Se modifico la descripcion para no concatenar el tar    */
/* item por eso aveces no se generaba el CFDI pues buscaba */
/* en el cat when then todo el texto completo y no lo      */
/* encontraba       .                                      */
/* ******************************************************* */
/*   ----OEYE----                04/10/2013 15:40          */
/* ******************************************************* */
  
SELECT folio = ivh_invoicenumber,  
       cantidad = abs(ivd_quantity), 
      
	   unidadmedida = 
	   
	     case when invoicedetail.ivd_quantity < 0 then 'ACT'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else

	   (
	   CASE (
             SELECT CONVERT(char, cht_description)
             FROM   chargetype A with (nolock)
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       ) WHEN 'Viaje (Peso Ton)' THEN 'Tonelada' ELSE 'No aplica' END
	   )
	   end, 
	  

	   unidadmedida33 = 
	   
	   
	   case when invoicedetail.ivd_quantity < 0 then 'Actividad'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else


	   ( SELECT ISNULL(cwt.NombreUnidad, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       )
	   end, 

	   claveunidad =

	    case when invoicedetail.ivd_quantity < 0 then 'ACT'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else
	   
	    ( SELECT ISNULL(cwt.UnidadSAT, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       )
	   
	   end, 
	   
	   
	   numidentificacion=
	   
	    case when invoicedetail.ivd_quantity < 0 then '84111506'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else

	   (
	    ( SELECT ISNULL(cwt.CodigoSAT, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       )
	   )end, 




	   consecutivo =
	   case when (select count(*) from invoicedetail a (nolock) where a.ivd_charge > 0 and a.cht_itemcode NOT IN ('PST', 'GST')  and a.ivh_hdrnumber =  invoicedetail.ivh_hdrnumber ) = 1 then 1 else
	   (select count(*) from invoicedetail a (nolock) where a.ivh_hdrnumber =  invoicedetail.ivh_hdrnumber ) - invoicedetail.ivd_sequence  -1
	   end,

      
	   idconcepto = 
	      case when invoicedetail.ivd_quantity < 0 then 'refact'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else

	   
	   
	   rtrim (
             (
                   SELECT CONVERT(char, cht_description)
                   FROM   chargetype A with (nolock)
                   WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
             )
       )
	   
	   end,-- + ' ' + ISNULL( invoicedetail.tar_tariffitem, ''), 
	  
	  
	  
	   descripcion = 
	   
	   
	   (
             SELECT ISNULL(
			 
			  (case when invoicedetail.ivd_quantity < 0 then 'Servicios de Facturación' else cwt.NombreUnidad +'-'+ cwt.cThen end)
			 

			,'OTROS' )
			
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       ), 



       valorunitario = ROUND (
             (
                   SELECT CASE WHEN invoicedetail.cht_itemcode = 'IVACOM' THEN 0 ELSE abs(ivd_rate) END 
             ), 2), 
       Importe = ROUND ( 
             (
                    SELECT CASE WHEN invoicedetail.cht_itemcode = 'IVACOM' THEN 0 ELSE abs(ivd_charge) END
             ), 2), 
       tasa_iva = '0.160000',
	   
	   /*
	   ( case when (select ivh_currency from invoiceheader i  where i.ivh_hdrnumber = invoicedetail.ivh_hdrnumber) = 'US$' then '0.000000'  else '0.160000' end ),   
             SELECT ISNULL(ivd_rate, 0) w
             FROM   invoicedetail A with (nolock)
             WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
               AND  A.ivd_charge > 0 
               AND  A.cht_itemcode = 'GST'*/

       tipo_imp = ( 
             SELECT ISNULL(ivd_description, '') 
             FROM   invoicedetail A with (nolock)
             WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
               AND  A.cht_itemcode = 'GST'


       ), 
	   impuestoiva = '002',
	   tipofactoriva = 'Tasa',
       iva_monto =  abs(ROUND (
             (
                   SELECT CASE 
                          WHEN invoicedetail.cht_itemcode = 'IVACOM' 
                          THEN ROUND( ivd_charge, 2) 
                          ELSE ISNULL(
                                (
                                      abs(ivd_charge) * ( 
                                            SELECT CASE WHEN cht_taxtable1 = 'Y' THEN 1 ELSE 0 END 
                                            FROM   chargetype A  with (nolock)
                                            WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
                                      ) * ( 
                                            SELECT isnull(ivd_rate, 0)
                                            FROM   invoicedetail A with (nolock)
                                            WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
                                              AND/*A.ivd_taxable1   = invoicedetail.ivd_taxable1 and */ 
                                                   A.ivd_charge <> 0 
                                              AND  A.cht_itemcode = 'GST'
                                      )
                                ) / 100, 0) 
                          END 
             ), 
       2)), 
       importe_iva_inc = abs(ROUND( 
             ivd_charge + (
                   SELECT ISNULL( ivd_charge, 0) 
                   FROM   invoicedetail A  with (nolock)
                   WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
                     AND  A.cht_itemcode = 'GST' 
             ), 2)), 

       tasa_ret = (  '0.040000' /*
             SELECT ABS( ISNULL(ivd_rate, 0) ) 
             FROM   invoicedetail A  with (nolock)
             WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
               AND  A.ivd_charge <> 0 
               AND/*A.ivd_taxable2   = invoicedetail.ivd_taxable2 and */
                    A.cht_itemcode = 'PST' */
       ), 
       Retencion = isnull((
             SELECT ISNULL(ivd_description, '') 
             FROM   invoicedetail A with (nolock)
             WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
               AND/*A.ivd_taxable2   = invoicedetail.ivd_taxable2 and  */ 
                    A.cht_itemcode = 'PST'
       ),''), 
	   impuestoret = '002',
	   tipofactorret = 'Tasa',
       ret_monto = ROUND( 
             ISNULL( 
                   ABS( 
                         ( 
                               SELECT ivd_charge /*concepto con retencion*/ 
                               FROM   invoicedetail B  with (nolock)
                               WHERE  B.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
                                 AND  B.ivd_number    = invoicedetail.ivd_number  /*B.ivd_taxable2 = 'Y'*/ 
                         ) * ( 
                               SELECT CASE WHEN cht_taxtable2 = 'Y' THEN 1 ELSE 0 END /*si el concepto lleva retencion*/ 
                               FROM          chargetype A  with (nolock)
                               WHERE      A.cht_itemcode = invoicedetail.cht_itemcode
                         ) * (
                               SELECT isnull(ivd_rate, 0) /*Tasa*/ 
                               FROM   invoicedetail A with (nolock)
                               WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
                                 AND  A.ivd_charge <> 0 
                                 AND  A.cht_itemcode = 'PST'
                         )
                   ) / 100, 0
             ), 2
       ), 
       importe_ret_inc = isnull(ROUND(
             ABS(
                   ivd_charge + 
                   (
                         SELECT ISNULL(ivd_charge, 0) 
                         FROM   invoicedetail A with (nolock)
                         WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND A.cht_itemcode = 'GST'
                   ) + isnull((
                         SELECT isnull(ivd_charge, 0) 
                         FROM   invoicedetail A with (nolock)
                         WHERE  A.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
                           AND A.ivd_taxable2 = invoicedetail.ivd_taxable2 
                           AND A.cht_itemcode = 'PST'
                   ),0.00)
             ), 2
       ) ,0.00)
 FROM  invoicedetail with (nolock), invoiceheader  with (nolock)
WHERE  invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
  AND  invoicedetail.cht_itemcode NOT IN ('PST', 'GST') 
  AND  ivd_charge <> 0 
  AND  CONVERT(VARCHAR, invoiceheader.ivh_printdate, 112) >= '20090701' /*dateadd(day,-2,getdate())*/ 
  AND  invoiceheader.ivh_invoicestatus = 'PRN' 
  AND  ivh_mbnumber = 0 

--Agregardo para agilizar la consulta se va directo a la tabla persistente
 and ivh_invoicenumber not in (Select invoice from Vista_fe_Generadas  with (nolock))





UNION 
/*--*********************CASO MASTER BILL*********************************************************************/ 
SELECT folio = (
             SELECT max(ivh_invoicenumber) 
             FROM   invoiceheader with (nolock)
             WHERE  ivh_mbnumber = F.ivh_mbnumber 
       ), 
       cantidad =  abs(round( round(SUM(ivd_charge),2) / abs(round(AVG(ivd_rate),2)),2))  ,
	    --abs(SUM(ivd_quantity)), 

       unidadmedida = CASE ( 
             SELECT CONVERT(char, cht_description) 
             FROM   chargetype A  with (nolock)
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       ) WHEN 'Viaje (Peso Ton)' THEN 'Tonelada' ELSE 'No Aplica' END, 
	  
	   unidadmedida33 =  
	   
	    case when sum(invoicedetail.ivd_quantity) < 0 then 'Actividad'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else
	   (
             SELECT ISNULL(cwt.NombreUnidad, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       )
	   end, 

	  claveunidad =
	   case when sum(invoicedetail.ivd_quantity) < 0 then 'ACT'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   else
	  
	    (
             SELECT ISNULL(cwt.unidadSAT, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       )
	   
	   end,
	    
	  numidentificacion=  
	  
	   case when sum(invoicedetail.ivd_quantity) < 0 then '84111506'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   
	   else
	  (
             SELECT ISNULL(cwt.CodigoSAT, 'NA')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       ) 
	   
	   end, 
	 consecutivo = 1,
	 
	 --case when (select distinct count(cht_itemcode) FROM   invoicedetail A  with (nolock) WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber and a.ivd_charge > 0 and a.cht_itemcode NOT IN ('PST', 'GST')) = 1 then 1 else  end,



       idconcepto =
	   
	   case when sum(invoicedetail.ivd_quantity) < 0 then 'refact'  --- si se trata de cantidad negativa es nota de credito por lo cual ponemos unidad ACT
	   
	   else
	  (
	   
	   
	    RTRIM( 
             (
                   SELECT CONVERT(char, cht_description) 
                   FROM   chargetype A  with (nolock)
                   WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
             )
       )
	   )
	   end,
	   
	   
	   -- + ' ' + ISNULL(invoicedetail.tar_tariffitem, ''), 
       descripcion = (
             SELECT ISNULL(
			 
			 
			  (case when sum(invoicedetail.ivd_quantity) < 0 then 'Servicios de Facturación' else cwt.NombreUnidad +'-'+ cwt.cThen end)
		
			 , 'OTROS')
             FROM   chargetype A with (nolock)
             LEFT JOIN catWhenThen cwt ON cwt.cWhen = A.cht_description 
                   AND cwt.iIdCatalogo = 2 
                   AND iStatus = 1
             WHERE  A.cht_itemcode = invoicedetail.cht_itemcode
       ), 



       valorunitario = ROUND ( 
             ( 
                   SELECT CASE WHEN invoicedetail.cht_itemcode = 'IVACOM' THEN 0 ELSE abs(AVG(ivd_rate)) END 
             ), 2
       ), 
       importe = ROUND(
             (
                   SELECT CASE WHEN invoicedetail.cht_itemcode = 'IVACOM' THEN 0 ELSE abs(SUM(ivd_charge)) END 
             ), 2 
       ), 
       tasa_iva = (  case when 
	   
	       (select ivh_currency from invoiceheader (nolock) where ivh_invoicenumber = f.ivh_invoicenumber) = 'US$' then '0.000000'  else '0.160000' end 
            
			/* SELECT ISNULL(abs(MAX(ivd_rate)), 0) 
             FROM   invoicedetail A  with (nolock)
             WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
               AND  ABS(ivd_charge) > 0 
               AND  A.cht_itemcode = 'GST'*/
       ), 
       tipo_imp = (
             SELECT ISNULL(MAX(ivd_description), '') 
             FROM   invoicedetail A  with (nolock)
             WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
               AND  ABS(ivd_charge) > 0 
               AND  A.cht_itemcode = 'GST'
       ), 
       /*iva_monto =  isnull( abs(sum(ivd_charge) * (select  
            case when cht_taxtable1 = 'Y'  then 1
            Else 0 
            end
            from chargetype A 
            where A.cht_itemcode =  invoicedetail.cht_itemcode )  *
             (select isnull(max(ivd_rate),0)  from  invoicedetail A
            where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
            abs(A.ivd_charge)  <> 0 and
            --A.ivd_taxable1   = invoicedetail.ivd_taxable1 and 
             A.cht_itemcode = 'GST')  / 100) ,0) ,*/ 
       impuestoiva = '002',
	   tipofactoriva = 'Tasa',
	   iva_monto = abs(ROUND(
             (
                   SELECT CASE 
                         WHEN invoicedetail.cht_itemcode = 'IVACOM' 
                         THEN ISNULL(ABS(SUM(ivd_charge)), 0) 
                         ELSE ISNULL(
                               ABS(
                                     SUM(ivd_charge) * 
                                     ( 
                                           SELECT CASE WHEN cht_taxtable1 = 'Y' THEN 1 ELSE 0 END 
                                           FROM   chargetype A  with (nolock)
                                           WHERE  A.cht_itemcode = invoicedetail.cht_itemcode 
                                     ) * ( 
                                           SELECT ISNULL(MAX(ivd_rate), 0) 
                                           FROM   invoicedetail A  with (nolock)
                                           WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
                                           AND (A.ivd_charge) <> 0 
                                           AND A.cht_itemcode = 'GST' 
                                     ) 
                               ) / 100, 0 
                         ) END 
             ), 2 
       )), 
       importe_iva_inc = abs(ROUND(SUM(ivd_charge) + 
             ( 
                   SELECT ISNULL(SUM(ivd_charge), 0) 
                   FROM   invoicedetail A  with (nolock)
                   WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
                   AND A.cht_itemcode = 'GST'
             ), 2
       )), 
       tasa_ret = ( '0.040000'
            /* SELECT ABS(ISNULL(abs(SUM(ivd_rate)), 0)) 
             FROM   invoicedetail A with (nolock)
             WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
               AND  A.ivd_charge <> 0 
               AND A.cht_itemcode = 'PST'*/
       ), 
       Retencion = (
             SELECT ISNULL(MAX(ivd_description), '') 
             FROM   invoicedetail A with (nolock)
             WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
               AND  A.cht_itemcode = 'PST'
       ), 
       /*ret_monto = isnull( abs( (sum(ivd_charge) * (select  
            case when cht_taxtable2 = 'Y'  then 1
            Else 0 
            end
            from chargetype A 
            where A.cht_itemcode =   invoicedetail.cht_itemcode )  * (select isnull(max(ivd_rate),0)  from  invoicedetail A
            where  A.ivh_hdrnumber  = F.ivh_hdrnumber and
            -- en mb si lleva la liga     
            A.ivd_taxable2   = invoicedetail.ivd_taxable2 and 
                A.cht_itemcode = 'PST' ))/ 100),0), */ 
       impuestoret = '002',
	   tipofactorret = 'Tasa',
	   ret_monto = ROUND(
             ISNULL( 
                   ABS( 
                         SUM(ivd_charge) * (
                               SELECT CASE WHEN cht_taxtable2 = 'Y' THEN 1 ELSE 0 END 
                               FROM   chargetype A with (nolock)
                               WHERE  A.cht_itemcode  = invoicedetail.cht_itemcode
                         ) * (
                               SELECT ISNULL(MAX(ivd_rate), 0) 
                               FROM   invoicedetail A /*Tasa*/  with (nolock)
                               WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
                                 AND  A.ivd_charge <> 0 
                                 AND A.cht_itemcode = 'PST'
                         ) / 100
                   ), 0
             ), 2
       ), 
       importe_ret_inc =isnull(abs( ROUND(
             SUM(ivd_charge) + ( 
                   SELECT ISNULL(abs(SUM(ivd_charge)), 0) 
                   FROM   invoicedetail A with (nolock)
                   WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
                     AND  ivd_charge > 0 
                     AND  A.cht_itemcode = 'GST' 
             ) + isnull(( 
                   SELECT ISNULL(SUM(ivd_charge), 0) 
                   FROM   invoicedetail A with (nolock)
                   WHERE  A.ivh_hdrnumber = F.ivh_hdrnumber 
                     AND  A.cht_itemcode = 'PST'  /*d_charge  > 0 and*/ 
             ),0.00), 2
       ) ),0.00)

	   --select *
FROM   vista_fe_invoicedetail invoicedetail with (nolock), invoiceheader with (nolock), vTTSTMW_FirstREg F 
WHERE  invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
  AND  invoicedetail.cht_itemcode NOT IN ('PST', 'GST') 
  AND  ivd_charge <> 0 
  AND  CONVERT(VARCHAR, invoiceheader.ivh_printdate, 112) >= '20090701' 
  AND  invoiceheader.ivh_mbnumber = F.ivh_mbnumber 
  AND  F.ivh_creditmemo = invoiceheader.ivh_creditmemo 
  

--agregado para agilizar consulta va a tabla persistente
 and F.ivh_mbnumber not in (Select nmaster from Vista_fe_Generadas with (nolock))



/*
AND  F.ivh_mbnumber IN (
      SELECT nmaster 
      FROM   VISTA_fe_Header with (nolock)
  )
*/

GROUP BY F.ivh_invoicenumber, F.ivh_hdrnumber, invoicedetail.cht_itemcode, F.ivh_creditmemo, --invoicedetail.tar_tariffitem,
 F.ivh_mbnumber
























GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'VISTA_Fe_detail', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VISTA_Fe_detail', NULL, NULL
GO
