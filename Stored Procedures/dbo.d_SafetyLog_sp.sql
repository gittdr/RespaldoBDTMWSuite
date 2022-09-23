SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_SafetyLog_sp] @srpID int
As
/* 
SR 17782 DPETE created 10/13/03 for retrieving and maintaining safety log.  

*/



Select slog_ID,
  srp_ID,
  slog_Date,
  slog_UpdateBY,
  slog_action
From SafetyLog
Where srp_ID = @srpID


GO
GRANT EXECUTE ON  [dbo].[d_SafetyLog_sp] TO [public]
GO
