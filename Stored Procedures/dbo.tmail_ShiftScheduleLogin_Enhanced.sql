SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmail_ShiftScheduleLogin_Enhanced] (@Drv VARCHAR(30), @Trc VARCHAR(30), @TRL VARCHAR(30), @LoginDATETIME VARCHAR(30), @Flags VARCHAR(30), @Trl2 VARCHAR(30) =NULL)
					 
AS
	exec dbo.tmail_ShiftScheduleLogin_Enhanced3 '', @Drv, @Trc, @Trl, @Trl2, @LoginDATETIME, @Flags, '125', '125'
GO
GRANT EXECUTE ON  [dbo].[tmail_ShiftScheduleLogin_Enhanced] TO [public]
GO
