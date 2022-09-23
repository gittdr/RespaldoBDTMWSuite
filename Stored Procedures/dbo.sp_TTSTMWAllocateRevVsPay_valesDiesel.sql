SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









-- 
--Drop sp_TTSTMWAllocateRevVsPay_valesDiesel
--exec sp_TTSTMWAllocateRevVsPay_valesDiesel 'EUC'
CREATE procedure [dbo].[sp_TTSTMWAllocateRevVsPay_valesDiesel]
(
@proyecto varchar(20)
)
AS
Declare @fechahoy datetime
Declare @ls_fechaini varchar(20)
Declare @ls_fechafin varchar(20)
Declare @ls_dia varchar(2)
Declare @ls_mes varchar(2)
Declare @ls_anio varchar(4)

select @fechahoy = getdate()


-- Fecha del día de Hoy
Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)

Select @ls_fechaini = @ls_anio+@ls_mes+@ls_dia

Select @ls_anio = Substring((select CONVERT(char(10), @fechahoy,111)),1,4)
Select @ls_mes  = Substring((select CONVERT(char(10), @fechahoy,111)),6,2)
Select @ls_dia  = Substring((select CONVERT(char(10), @fechahoy,111)),9,2)


Select @ls_fechafin = @ls_anio+@ls_mes+@ls_dia+' 23:59:59'



Delete from MR_SessionID where ses_SPID=@@SPID 
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'ActiveTargetedCurrency','MX$')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypeRevenue','Delivery Date')  
Insert into MR_SessionID(ses_SPID,ses_key,ses_value) Values (@@SPID,'CurrencyDateTypePay','Pay Period Date') 
				  --Execute sp_TTSTMWAllocateRevVsPay 'D','20120528','20120528 23:59:59','','','',' ','N','Y','N','STD,CMP',' ',' ',@proyecto,' ',' ',' ',' ',' ',' ',' ',' ',' ','N','B','VALECO',' '
Execute sp_TTSTMWAllocateRevVsPay_analisisValesDiesel 'D','20120528','20120528 23:59:59','','','',' ','N','Y','N','STD,CMP',' ',' ',@proyecto,' ',' ',' ',' ',' ',' ',' ',' ',' ','N','B','VALECO',' '
--@lgh_class3 --Valor
--@FirstBillTo
--Consulta para traer agrupados los movimientos solo con los vales
/*
select fuelticket.mov_number, sum(fuelticket.ftk_liters) as Liters,  sum(AllocatedTotlChargesForLgh) as ATChargesForLgh, sum(CompensationForLegHeader) as CFLegHeader, (select (sum(CompensationForLegHeader)/ sum(AllocatedTotlChargesForLgh))*100) as Porcentaje
from  LegHeaderSummary_SSRS_ValesDiesel
left outer join fuelticket on 
LegHeaderSummary_SSRS_ValesDiesel.mov_number = fuelticket.mov_number and
LegHeaderSummary_SSRS_ValesDiesel.lgh_number = fuelticket.lgh_number
where  
fuelticket.mov_number is not null and ftk_ticket_number not  in (select ftk_ticket_number from fuelticket where fuelticket.ftk_recycled = 'Y') 
and ftk_ticket_number in (select ftk_ticket_number from fuelticket where(ftk_canceled_by is Null)) 
group by fuelticket.mov_number
order by fuelticket.mov_number asc
*/

--Consulta para traer todos los movimientos con vales cancelados, no cancelados, reciclados, no reciclados, impresos y no impresos
--select * from LegHeaderSummary_SSRS_ValesDiesel where mov_number=172111
Delete from MR_SessionID where ses_SPID=@@SPID










GO
