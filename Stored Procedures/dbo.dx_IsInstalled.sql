SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  proc [dbo].[dx_IsInstalled]
as
begin
	select 1
end

GRANT  EXECUTE  ON [dbo].[dx_IsInstalled]  TO [public]
GO
