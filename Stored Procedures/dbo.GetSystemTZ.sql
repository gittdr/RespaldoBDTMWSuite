SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetSystemTZ] @SystemTZ int OUT, @SystemDSTCode int OUT, @SystemTZMins int OUT
as
	SELECT @SystemTZ = NULL, @SystemDSTCode = NULL, @SystemTZMins = NULL

        SELECT @SystemTZ = CASE WHEN ISNUMERIC(text)<>0 THEN CONVERT(int, text) ELSE NULL END
        FROM tblRS
        WHERE KeyCode = 'SysTZ'

        SELECT @SystemDSTCode = CASE WHEN ISNUMERIC(text)<>0 THEN CONVERT(int, text) ELSE NULL END
        FROM tblRS
        WHERE KeyCode = 'SysDSTCode'

        SELECT @SystemTZMins = CASE WHEN ISNUMERIC(text)<>0 THEN CONVERT(int, text) ELSE NULL END
        FROM tblRS
        WHERE KeyCode = 'SysTZMins'

GO
GRANT EXECUTE ON  [dbo].[GetSystemTZ] TO [public]
GO
