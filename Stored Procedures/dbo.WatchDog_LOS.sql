SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_LOS] 
(

	@TempTableName varchar(255)='##WatchDog_LOS',
	@WatchName varchar(255)='Nivel de Servicio',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @cliente varchar(20),
    @mensem varchar(7)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables



	-- Initialize Temp Table

if @mensem = 'semana'
 begin 	

	SELECT 

	Orden = s.sxn_ord_hdrnumber,
	Fecha = s.sxn_expdate,
	Tipo =  (select name from labelfile where labeldefinition = 'ReasonLate' and abbr = s.sxn_expcode),
	Descripcion =  s.sxn_description, 
	[Accion Tomada] = sxn_action_received_desc,
	Origen =  o.ord_originpoint,
	Destino = o.ord_destpoint ,
	[Compañia] = sxn_cmp_id
		
	 into   	#TempResults
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
		WHERE 
	datediff(ww,s.sxn_expdate,getdate()) = 0
	and s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	and o.Ord_billto = @cliente
 
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


end    


else if  @mensem = 'mes'

 begin
   	SELECT 

	Orden = s.sxn_ord_hdrnumber,
	Fecha = s.sxn_expdate,
	Tipo =  (select name from labelfile where labeldefinition = 'ReasonLate' and abbr = s.sxn_expcode),
	Descripcion =  s.sxn_description, 
	[Accion Tomada] = sxn_action_received_desc,
	Origen =  o.ord_originpoint,
	Destino = o.ord_destpoint ,
	[Compañia] = sxn_cmp_id
		
	 into   	#TempResults2
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
		WHERE 
    datediff(mm,s.sxn_expdate,getdate()) = 0
	and s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	and o.Ord_billto = @cliente


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults2'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults2'
	End

	Exec (@SQL)
	Set NoCount Off






end










GO
