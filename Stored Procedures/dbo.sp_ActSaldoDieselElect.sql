SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_ActSaldoDieselElect] as


Declare @tractor varchar(20)
Declare @saldo float
Declare @V_registros integer
Declare @V_i integer


select @V_registros =  (select count(*)  from TractorProfile where trc_number in (select tca_tractor from tractoraccesories where tca_type = 'TDE'))

select @V_i = 1



		DECLARE saldoedenredcursor CURSOR FOR 
		(select tractor, sum(Costo) as Costo from  fuelticketelect group by  Tractor)

		OPEN saldoedenredcursor  
				FETCH NEXT FROM saldoedenredcursor  INTO @tractor,@saldo
			WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
					BEGIN 
					if left(@tractor,3) = 'TCU' 
					 update trailerprofile set trl_saldoedenred =  @saldo 
					  where trl_number = @tractor and trl_status <> 'OUT'
					ELSE
					  update tractorprofile set trc_saldoedenred =  @saldo 
					  where trc_number = @tractor and trc_status <> 'OUT'
					
			select @V_i = @V_i + 1

					FETCH NEXT FROM saldoedenredcursor  INTO @tractor,@saldo
			
	    END --3 curso de los movimientos 

	    CLOSE saldoedenredcursor 
	    DEALLOCATE saldoedenredcursor 

GO
