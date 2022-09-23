SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.timerins    Script Date: 6/1/99 11:54:39 AM ******/
create PROCEDURE [dbo].[timerins]	@where varchar (24), 
										@comment varchar (255)

AS

DECLARE @num int

EXEC @num = getsystemnumber "TIMER", "" 

INSERT INTO ttstimer
VALUES (@num, @where, GetDate(), "", @comment, 0 )


return



GO
GRANT EXECUTE ON  [dbo].[timerins] TO [public]
GO
