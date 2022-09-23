SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_notes2_sp] @notetable varchar(18) = NULL, @tablekey varchar(18), @notetype varchar(75) = NULL AS
	exec dbo.tmail_get_notes4_sp @notetable, @tablekey, @notetype, ''
GO
GRANT EXECUTE ON  [dbo].[tmail_get_notes2_sp] TO [public]
GO
