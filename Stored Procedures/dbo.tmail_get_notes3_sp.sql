SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_notes3_sp] @notetable varchar(18), @tablekey varchar(18), @notetype varchar(6), @NoWrapFlag VARCHAR(30) AS
	EXEC dbo.tmail_get_notes2_sp @notetable, @tablekey, @notetype 
GO
GRANT EXECUTE ON  [dbo].[tmail_get_notes3_sp] TO [public]
GO
