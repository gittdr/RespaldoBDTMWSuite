SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Store Procdure que lee el consecutivo de la base de datos de TDR.

CREATE PROCEDURE [dbo].[sp_obtengo_consecutivo_vales_consolidado] as 

DECLARE @i_totalmsgs1            integer,
	@i_totalmsgs4            integer,
	@msg_error		varchar(30)



----execute @i_totalmsgs4 = tmwdes..getsystemnumber_gateway N'FUELTICK' , NULL , 1 
execute @i_totalmsgs4 = tmwSuite..getsystemnumber_gateway N'FUELTICK' , NULL , 1 

update paso_consecutivo_valescomb
set id_consecutivovalescomb = @i_totalmsgs4
where renglon = 1;


Return @i_totalmsgs4

GO
