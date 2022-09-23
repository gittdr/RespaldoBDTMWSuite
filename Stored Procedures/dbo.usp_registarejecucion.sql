SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_registarejecucion]
as
begin
	INSERT INTO STALIVERDED (fecha) VALUES(GETDATE())	
end
GO
