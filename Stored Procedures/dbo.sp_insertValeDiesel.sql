SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_insertValeDiesel] (
@city_a int,
@city_b int, 
@operado varchar(50),
@orden int,
@usuario varchar (50) ,
@tractor varchar (20) ,
@litros float,
@movimiento int,
@segmento int
) as 

DECLARE @i_totalmsgs1            integer,
	@i_totalmsgs4            integer,
	@msg_error		varchar(30),
	@precio float,
	@monto float


select @precio = (SELECT top 1 averagefuelprice.afp_price FROM averagefuelprice (nolock) WHERE ( averagefuelprice.afp_tableid = '4' ) order by afp_date desc)
select @monto = @precio * @litros


----execute @i_totalmsgs4 = tmwdes..getsystemnumber_gateway N'FUELTICK' , NULL , 1 
execute @i_totalmsgs4 = tmwSuite..getsystemnumber_gateway N'FUELTICK' , NULL , 1 


  --Modificado por Emolvera 01/02/2014 para que  los tractos que tengan como accesorio una tarjeta de diesel electronica TDE ya se pongan impresos
	if @tractor in (select tca_tractor from tractoraccesories where tca_type IN( 'TDE','TSO','TPE'))
		Begin
		  INSERT INTO fuelticket ( ftk_ticket_number, ftk_cty_start, ftk_cty_end, drv_id, ord_hdrnumber, ftk_created_on, ftk_created_by, ftk_updated_by,trc_id, ftk_liters,ftk_cost,mov_number, lgh_number, ftk_printed_by, ftk_printed_on, ftk_recycled,ftk_invoice ) 
		  VALUES (@i_totalmsgs4 , @city_a, @city_b, @operado, @orden, getdate(), '_'+@usuario,@usuario, @tractor, @litros,@monto, @movimiento, @segmento,'VELEC',getdate(), 'N' ,'PC')
		END
    else
	   Begin
		  INSERT INTO fuelticket ( ftk_ticket_number, ftk_cty_start, ftk_cty_end, drv_id, ord_hdrnumber, ftk_created_on, ftk_created_by, ftk_updated_by,trc_id, ftk_liters,ftk_cost,mov_number, lgh_number, ftk_recycled ) 
		  VALUES (@i_totalmsgs4 , @city_a, @city_b, @operado, @orden, getdate(), '_'+@usuario,@usuario, @tractor, @litros,@monto, @movimiento, @segmento, 'N' )
		END
    

Return @i_totalmsgs4
GO
