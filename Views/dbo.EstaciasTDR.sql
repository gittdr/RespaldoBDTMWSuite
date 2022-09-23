SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view  [dbo].[EstaciasTDR] as
(
select   [pyt_itemcode], [pyt_description], [asgn_id], [ord_hdrnumber], [mov_number], [pyd_description], [pyd_amount], [pyd_createdon], [pyh_payperiod], [aniopago], [mespago], [semanapago], [diapago], [aniocrea], [mescrea], [semanacrea], [diacre], [pyd_authcode], [pyd_createdby], [pyd_status], [difdias], [tractor], [proyecto], [usr_fname], [usr_lname], [sucursal], [Expr1], [pyd_remarks], [ord_billto], [cmp_id_start], [cmp_id_end]
  from [dbo].[vista_ant_y_gastos_parte1] where 
 pyt_itemcode in ('COMEST','COBEST','ECC')

 and  pyh_payperiod > '2018-01-01')
GO
