SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_default_ini_role] @user varchar (20)
AS
SET NOCOUNT ON
DECLARE @role table (role VARCHAR (8), sort integer)
INSERT INTO @role (role, sort)
	SELECT con_asgnrole, 1
		FROM config_role_assignment
		WHERE con_asgnuser = @user

INSERT INTO @role (role, sort)
	SELECT TOP 1 con_asgnrole, 2
		FROM config_role_assignment JOIN ttsgroupasgn ON con_asgngroup = grp_id
		WHERE @user = usr_userid
		ORDER BY con_asgnrole DESC

INSERT INTO @role (role, sort) VALUES ('UNK', 3)

SELECT TOP 1 role FROM @role order by sort
GO
GRANT EXECUTE ON  [dbo].[d_get_default_ini_role] TO [public]
GO
