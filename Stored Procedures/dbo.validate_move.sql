SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[validate_move] @mov_number int
AS
CREATE TABLE #err (ord_hdrnumber int,
	                   ord_number varchar(12),
	                   err_msg varchar(100))

SELECT * FROM #err
DROP TABLE #err
GO
GRANT EXECUTE ON  [dbo].[validate_move] TO [public]
GO
