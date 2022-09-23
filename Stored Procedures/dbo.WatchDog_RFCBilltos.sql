SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_RFCBilltos] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogRFCBillto',
	@WatchName varchar(255)='RFCbilltos',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected' 
    
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables
declare @rfcs table (compania varchar(max), ID varchar(10),Status varchar(200), RFC varchar(20), StatusBillto varchar(20), Pais varchar(20))

insert into @rfcs

select    cmp_name, cmp_id, 
case 
when cmp_taxid is null then '--SIN RFC - EL BILLTO ACTIVO NO CUENTA CON UN RFC CAPTURADO---' 
when (len(cmp_taxid) > 13  )   then '--RFC SOBRAN CARACTERES (USAR SOLO LETRAS Y NUMEROS SIN ESPACIOS)--' 
when (len(cmp_taxid)< 12 )   then '--RFC FALTAN CARACTERES (USAR SOLO LETRAS Y NUMEROS SIN ESPACIOS)--'
else cmp_taxid end as estatus,
isnull(cmp_taxid,'')  as rfccapturado,
cmp_crmtype as 'StatusBillto',
cmp_country as 'Pais'
 from company where (cmp_crmtype not in ('PROS','LEAD')) and cmp_billto = 'Y' and cmp_active = 'Y' and 
 (cmp_taxid is null or (len(cmp_taxid) > 13  or (len(cmp_taxid)< 12 ) )) and (cmp_country) = 'MEXICO' 


 insert into @rfcs

select    cmp_name, cmp_id, 
case 
when cmp_taxid is null then '--SIN TAX ID - EL BILLTO EXTRANJERO ACTIVO NO CUENTA CON UN TAX ID CAPTURADO---' 
when ((cmp_taxid) = 'XEXX010101000')   then '--CAMBIAR EL TAX ID DEL BILLTO EXTRANJERO POR EL TAX ID REAL--' 

else cmp_taxid end as estatus,
isnull(cmp_taxid,'')  as rfccapturado,
cmp_crmtype as 'StatusBillto',
cmp_country as 'Pais'
 from company where (cmp_crmtype not in ('PROS','LEAD')) and cmp_billto = 'Y' and cmp_active = 'Y' 
 and (cmp_taxid = 'XEXX010101000' or cmp_taxid is null) and (cmp_country) <> 'MEXICO' 



select * 
into  	#TempResults
from @rfcs



	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End

	Exec (@SQL)
	Set NoCount Off








GO
