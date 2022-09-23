SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadlegalentity_sp] @legalentity varchar(40) , @number int AS

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT le_id FROM legal_entity WHERE le_id like @legalentity + '%' ) 
	SELECT  le_name , le_id
          FROM legal_entity 
         WHERE le_id like @legalentity + '%' 
         ORDER BY le_name 
else 
	SELECT 'UNKNOWN','UNK'

set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_loadlegalentity_sp] TO [public]
GO
