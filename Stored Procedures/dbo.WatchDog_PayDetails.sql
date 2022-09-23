SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_PayDetails] 
(

    @MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='PayDetails',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @PayItemCodeList varchar(255)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


Set @PayItemCodeList= ',' + ISNULL(@PayItemCodeList,'') + ','


	-- Initialize Temp Table
	

      select 
      Movimiento = mov_number,
      Hora = SUBSTRING ( CONVERT(char(38),  pyd_transdate,121), 12,8),
      Litros = dbo.fnc_TMWRN_FormatNumbers( pyd_quantity,2) ,
      Cantidad =  '$' + dbo.fnc_TMWRN_FormatNumbers(pyd_amount,2) ,
      CreadoPor = (select nombre from tdrsilt.dbo.seguridad_usuarios where id_usuario =
        (select ftk_created_by from fuelticket where fuelticket.mov_number =paydetail.mov_number and ftk_created_by 
         in (select id_usuario from tdrsilt.dbo.seguridad_usuarios))),
      Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select lgh_driver1 from legheader where legheader.mov_number = paydetail.mov_number)),
      Unidad = (select lgh_tractor from legheader where legheader.mov_number = paydetail.mov_number)
      into   	#TempResults
      from paydetail 
      where
      DateDiff(mi,pyd_transdate,GetDate())>= @MinThreshold
	  AND 
      DateDiff(mi,pyd_transdate,getdate())<= -@MinsBack
      and   ( @PayItemCodeList  =',,' or CHARINDEX(',' + pyt_itemcode  + ',', @PayItemCodeList ) > 0)
      order by Hora

 


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
