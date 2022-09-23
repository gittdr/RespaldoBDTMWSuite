SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_SaldoBancos] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogSaldoBancos',
	@WatchName varchar(255)='SaldoBancos',
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



--************************************************************CREAR TABLAS PARA CONTENER LOS SALDOS DE LAS CUENTAS*******************************************************************************************************************************
CREATE TABLE #SaldoFin
    ([Fecha trans.] datetime, 
     [Número de cuenta] varchar(15),
     [Descripción cuenta] varchar (500), 
     [Saldo Inicial] float,
     Entradas float,
     Salidas float,
     [Saldo Final] float,
     Referencia  varchar(200),
     Tipo varchar(3),
     Ordena int)

CREATE TABLE #SaldoFinDos
    ([Fecha trans.] datetime, 
     [Número de cuenta Dos] varchar(15),
     [Descripción cuenta] varchar (500), 
     [Saldo Inicial] float,
     Entradas float,
     Salidas float,
     [Saldo Final] float,
     Referencia  varchar(200),
     Tipo varchar(3),
     Ordena int)


--Obtenemos saldos del perido actual----------------------------------------------------------------------------------------------------------------------------------------

--saldo para las cuentas en MNX----------------------------------------------------------
insert into #SaldoFin

	select 
    getdate(),
	Cuenta = (select ACTNUMST from  [172.24.16.113].TDR.dbo.GL00105 a where  b.ACTINDX =   a.ACTINDX ),
	desccuenta = (select ACTDESCR from  [172.24.16.113].TDR.dbo.[GL00100] a where  b.ACTINDX =   a.ACTINDX ),
    0,
    0.0,
    0.0,
	sum(PERDBLNC),
	--sum(CRDTAMNT),
	--sum(DEBITAMT)
    'SALDO',
    'MNX',
    1 
	from  [172.24.16.113].TDR.dbo.[GL10110] b
	WHERE 
	ACTINDX in (SELECT ACTINDX FROM  [172.24.16.113].TDR.dbo.GL00105  where ACTNUMST in
		 ('00-00-1102-0001',
          -- quitar por que sam lo pidio '00-00-1102-0002',
           -- '00-00-1102-0003',
		    '00-00-1102-0008',
            '00-00-1102-0010',
            '00-00-1102-0011',
             -- cancelada 06/06/14 '00-00-1102-0012',
		    -- '00-00-1102-0013',
			 '00-00-1103-0002','00-00-1103-0004','00-00-1103-0005'))
	group by  ACTINDX 


--saldo para las cuentas en USD------------------------------------------------------------
insert into #SaldoFin

  select 
  getdate(),
  [Número de cuenta],
  [Descripción cuenta],
  0,
  0.0,
  0.0,
  (sum([Monto débito original]) - sum([Monto crédito original])), 
  'SALDO',
  'MNX',
  1 
  from  [172.24.16.113].TDR.dbo.AccountTransactions 
  where  [Número de cuenta] in 
  ('00-00-1102-0004',  
   --cuenta cancelada 06/06/2014 '00-00-1102-0005',
   '00-00-1102-0009')


--************************************************************************************************************************************
                                       --ACTUALIZAR FECHAS MOVIMIENTOS Y SALDOS A PARTIR 
--************************************************************************************************************************************
  and year([Fecha trans.]) >=  year(getdate())
   and month([Fecha trans.]) >=  month(getdate())  
--************************************************************************************************************************************
  group by  [Número de cuenta], [Descripción cuenta]


--insertar cuentas en dolares con saldos en 0
insert into #SaldoFin
 select distinct
  getdate(),
  [Número de cuenta],
  [Descripción cuenta],
  0.0,
  0.0,
  0.0,
  0.0, 
  'SALDO',
  'MNX',
  1 
  from  [172.24.16.113].TDR.dbo.AccountTransactions 
  where  [Número de cuenta] in 
('00-00-1102-0004',
--cuenta cancelada 06/06/2014  '00-00-1102-0005',
  '00-00-1102-0009')
  and [Número de cuenta]  not in (select [Número de cuenta]  from #SaldoFin)
  

 /***************************************************************************************************************************************************************************************************************************/

 update #SaldoFin set [Saldo Final] =  [Saldo Final] +  cast(105854.89 as float)  where [Número de cuenta] = '00-00-1102-0004'  and   Referencia = 'SALDO' --compass
--Cuenta CANCELADA 06/06/2014
--update #SaldoFin set [Saldo Final] =  [Saldo Final] +  cast(0.00 as float)  where [Número de cuenta] = '00-00-1102-0005'  and   Referencia = 'SALDO' --ban 549
 update #SaldoFin set [Saldo Final] =  [Saldo Final] +  cast(2819.18 as float)   where [Número de cuenta] = '00-00-1102-0009'  and   Referencia = 'SALDO' --ban 657

	 
--************************************************************INSERTAR TRANSACCIONES POR CUENTA*******************************************************************************************************************************

insert into #SaldoFin

select 
[Fecha trans.],
[Número de cuenta],
'',
0,
[Monto débito original],
[Monto crédito original] * -1,
0,
Referencia,
'MNX',
2 as Ordena

from  [172.24.16.113].TDR.dbo.AccountTransactions
where [Número de cuenta] IN

('00-00-1102-0001',
--quitar por que sam lo pidio '00-00-1102-0002',
--'00-00-1102-0003',
'00-00-1102-0004',
--quitar por que sam lo pidio '00-00-1102-0005',
'00-00-1102-0008','00-00-1102-0009','00-00-1102-0010',
'00-00-1102-0011',
--quitar por que sam lo pidio 06/06/14 '00-00-1102-0012',
--'00-00-1102-0013',
'00-00-1103-0002','00-00-1103-0004','00-00-1103-0005')
and datediff(dd,[Fecha trans.],getdate()) = 0


--************************************************************TRANSFORMACION DE DATOS*******************************************************************************************************************************


--MARCAR LAS CUENTAS QUE SON DE DOLARES--------------------------------------------------------------------------------------------------------------------------
update #SaldoFin set Tipo = 'USD' where [Número de cuenta] in ('00-00-1102-0004','00-00-1102-0005','00-00-1102-0009')
--MARCAR LAS CUENTAS QUE SON DE INVERSION------------------------------------------------------------------------------------------------------------------------
update #SaldoFin set Tipo = 'INV' where [Número de cuenta] in ('00-00-1103-0004','00-00-1103-0005','00-00-1103-0002')
--CALCULO DE SALDOS INICIALES------------------------------------------------------------------------------------------------------------------------------------
--COPIAMOS DATOS A TABLA GEMELA PARA OBTENER EL RESUMEN DE SALDOINICIAL,SALDOFINAL,SALIDAS,ENTRADAS--------------------------------------------------------------
insert into #SaldoFinDos
select * from #SaldoFin
---saldo inicial para cuentas con movimiento.
update #SaldoFin  set [Saldo Inicial] =  [Saldo Final] - (Select sum(entradas+salidas) from #SaldoFinDos where [Número de Cuenta] = [Número de Cuenta Dos] and Ordena = 2)
where Ordena = 1
---saldo inicial para cuentas sin movimientos, es el mismo que el final------------------------------------------------------------------------------------------
update #SaldoFin  set [Saldo Inicial]  = [Saldo Final]
Where [Saldo Inicial] is null 
--CALCULO DE MONTO DE ENTRADAS-----------------------------------------------------------------------------------------------------------------------------------
update #SaldoFin  set Entradas =   (Select sum(entradas)  from #SaldoFinDos where [Número de Cuenta] = [Número de Cuenta Dos] and Ordena = 2)
where Ordena = 1
--CALCULO DE MONTO DE SALIDAS------------------------------------------------------------------------------------------------------------------------------------
update #SaldoFin  set Salidas =   (Select sum(Salidas) from #SaldoFinDos where [Número de Cuenta] = [Número de Cuenta Dos] and Ordena = 2)
where Ordena = 1

--************************************************************DESPLIEGUE DE LOS RESULTADOS*******************************************************************************************************************************

--SALDOS DE LAS CUENTAS-------------------------------------------------------------
select 
--[Fecha trans.],
[Número de cuenta] ,
[Descripción cuenta],
 '$' + dbo.fnc_TMWRN_FormatNumbers([Saldo Inicial],2) as [Saldo Inicial del día],
 '$' + dbo.fnc_TMWRN_FormatNumbers(Entradas,2) as [Entradas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(Salidas,2)  as [Salidas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers([Saldo Final],2)  as [Saldo Final del día],
 Tipo
into #TempResults
 from #SaldoFin
Where ordena = 1


UNION


--TOTAL CUENTAS CORRIENTES------------------------------------------------------------
select 
--getdate(),
'**************',
'**********TOTAL CTAS CORRIENTES*********',
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Inicial]),2) as [Saldo Inicial del día],
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Entradas),2)as [Entradas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Salidas),2) as [Salidas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Final]),2)  as [Saldo Final del día],
'MNX'
 from #SaldoFin
Where ordena = 1 and Tipo = 'MNX'


UNION

--TOTAL CUENTAS EN DOLARES------------------------------------------------------------
select 
--getdate(),
'**************',
'****************TOTAL DOLARES***************',
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Inicial]),2) as [Saldo Inicial del día],
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Entradas),2)as [Entradas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Salidas),2) as [Salidas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Final]),2)  as [Saldo Final del día],
'USD'

 from #SaldoFin
Where ordena = 1 and Tipo = 'USD' 



UNION

--TOTAL CUENTAS EN INVERSIONES-----------------------------------------------------
select 
--getdate(),
'**************',
'*************TOTAL INVERSIONES*************',
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Inicial]),2) as [Saldo Inicial del día],
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Entradas),2)as [Entradas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Salidas),2) as [Salidas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Final]),2)  as [Saldo Final del día],
'INV'

 from #SaldoFin
Where ordena = 1 and Tipo = 'INV'

UNION


--TOTAL CUENTAS PESOS------------------------------------------------------------
select 
--getdate(),
'**************',
'**********TOTAL CTAS PESOS*****************',
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Inicial]),2) as [Saldo Inicial del día],
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Entradas),2)as [Entradas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Salidas),2) as [Salidas del día], 
 '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Saldo Final]),2)  as [Saldo Final del día],
'MNXZ'
 from #SaldoFin
Where ordena = 1 and Tipo in ('MNX','INV')




--ORDENAR POR MONEDA Y MANDAR TOTALES AL FINAL DEL GRUPO-------------------------------
order by Tipo,[Descripción cuenta] desc




/*

select 
[Fecha trans.],
[Número de cuenta] ,
[Descripción cuenta],
 replace('$' + dbo.fnc_TMWRN_FormatNumbers([Saldo Inicial],2),'$0.00','') as [Saldo Inicial del día],
 replace('$' + dbo.fnc_TMWRN_FormatNumbers(Entradas,2),'$0.00','') as [Entradas del día], 
 replace('$' + dbo.fnc_TMWRN_FormatNumbers(Salidas,2),'$0.00','') as [Salidas del día], 
 replace('$' + dbo.fnc_TMWRN_FormatNumbers([Saldo Final],2),'$0.00','') as [Saldo Final del día],
Referencia

 from #SaldoFin
Where ordena = 2
ORDER BY [Número de cuenta], Ordena 
*/


DROP TABLE #SALDOFIN
DROP TABLE #SALDOFINDOS




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
