SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 03/2/00 MZ: */
CREATE PROCEDURE [dbo].[tmail_altaddressing_results]  @tractor varchar(8),
 						  @driver varchar (8),
						  @msgdate datetime,
						  @scheme varchar (5)
AS
	exec dbo.tmail_altaddressing_results2 @tractor, @driver, @msgdate, @scheme, ''
GO
GRANT EXECUTE ON  [dbo].[tmail_altaddressing_results] TO [public]
GO
