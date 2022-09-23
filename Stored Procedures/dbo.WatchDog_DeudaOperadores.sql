SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  Proc [dbo].[WatchDog_DeudaOperadores] 
(

    @Umbraldeuda float = 10000,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='PayDetails',
	@ThresholdFieldName varchar(255) = '',
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


----INICIALIZAR TABLA TEMPORAL CON VALORES DE LA CONSULTA--------------------------------------------------------------------------------------------------------

 
       CREATE TABLE #DeudaOpDog(Concepto varchar(255), Descripcion varchar(900), Fecha datetime, Operador varchar(600), Flota varchar(200),
       Balance float )
   
     
			Insert into #DeudaOpDog
			
		SELECT 
 
		Concepto = standingdeduction.sdm_itemcode,
		Descripcion = standingdeduction.std_description,
		Fecha = std_issuedate,
		Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = asgn_id), 
        Flota = (Select name from labelfile where labeldefinition = 'Fleet' and abbr = (select mpp_fleet from manpowerprofile where mpp_id = asgn_id)),
		standingdeduction.std_balance
		--,standingdeduction.std_status

		--,standingdeduction.std_balance * (case when standingdeduction.std_startbalance = 0 and dbo.standingdeduction.std_endbalance = 0 then -1 when stdmaster.sdm_minusbalance = 'N' then 1 else -1 end) cabs_balance, standingdeduction.std_startbalance - standingdeduction.std_endbalance cabs_issueamount,
		FROM standingdeduction join manpowerprofile on standingdeduction.asgn_id = manpowerprofile.mpp_id
		join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode

		WHERE standingdeduction.asgn_type = 'DRV'
		and 'UNKNOWN' in ('UNKNOWN', standingdeduction.asgn_id)
		and standingdeduction.sdm_itemcode in ('ACC','LIQUID','ALIMEN', 'ISPTAM', 'ANTI', 'CONTEQ', 'CREDEN', 'DEF', 'DENT', 'DEVO', 'DIESEL', 'EQSEG', 'EVID','FMERC', 'EQUIPO', 'DEP', 'INC','LAB','LIC','LEC','LLANT','LOD','LUC','MEMB','OFTAL','PREPER','PROMO','CEMS','INFOAM','IAVE','UNIFOR','ZAPA', 'IMSSAM', 'INF')
		and standingdeduction.std_status in ('INI','DRN','HLD','XXX','XXX','XXX','XXX')
		and standingdeduction.std_issuedate between {ts '1950-01-01 00:00:00.000'} and {ts '2049-12-31 23:59:59.992'}
		--itemCode considerados que se quitaron a peticion de Karla 12-02-2013 
		--'SEGVID', 'PATGAM', 'PATKRA', 'PATMTY', 'PATOAX', 'PATSAY', 'PATTOR', 'PRIMVA', 'PAGARE', 'COMPE', 'PA', 'FONA', 'INF', 'VACAS', 'BONO', 'AGNALD','AGUINA',
--'ACC','LIQUID','ALIMEN','ISPTAM','ANTI','CONTEQ','CREDEN','DEF','DENT','DEVO','DIESEL','EQSEG','EVID',		'FPGAM','FPHER','FPJMX','FPKFT','FPMTY','FPSAYE','FPSAOX','FPST','FPGDL','FMERC','EQUIPO','FALTA','DEP','IMSSA','RISTRA','INC','ISRAGU','LAB','LIC','LEC','LLANT','LOD','LUC','MEMB','OFTAL','INSTRU','PREPER','PROMO','IMSSRE','CEMS','INFOAM','PATGDJ','PATHER','PATJUM','PATMEX','IAVE','TMPEXT','UNIFOR','ZAPA'

		and 'UNK' in ('UNK', manpowerprofile.mpp_type1)
		and 'UNK' in ('UNK', manpowerprofile.mpp_type2)
		and 'UNK' in ('UNK', manpowerprofile.mpp_type3)
		and 'UNK' in ('UNK', manpowerprofile.mpp_type4)
		and 'UNK' in ('UNK', manpowerprofile.mpp_company)
		and 'UNK' in ('UNK', manpowerprofile.mpp_fleet)
		and 'UNK' in ('UNK', manpowerprofile.mpp_division)
		and 'UNK' in ('UNK', manpowerprofile.mpp_domicile )
		and 'X' in ('X', manpowerprofile.mpp_actg_type)  
		and manpowerprofile.mpp_status <> 'OUT'

  

   
    
--DESPLIEGUE DEL DETALLE-----------------------------------------------------------------------------------------------------------------------------------------------------------

 CREATE TABLE #DeudaOpDog2 (Operador varchar(600),Balance float )
  
  insert into  #DeudaOpDog2

		select  

            Operador,
            Balance = sum(balance)
		     from #DeudaOpDog
           group by operador
           order by cast( sum(balance) as int)  DESC
            --order by (select cast( sum(balance) as int) from #TempResults group by Operador) DESC
           
select  

            Operador,
            Balance = '$' + dbo.fnc_TMWRN_FormatNumbers(sum(balance),2)
            into   	#TempResults
		     from #DeudaOpDog2
            where balance > @umbraldeuda
           group by operador
           order by cast( sum(balance) as int)  DESC
            --order by (select cast( sum(balance) as int) from #TempResults group by Operador) DESC



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
