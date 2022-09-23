SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_getrole_sp] @user VARCHAR(20)
AS
SET NOCOUNT ON
DECLARE @groups table (grp_id varchar(50))
declare @roles table (rol_id varchar(50))

INSERT INTO @groups
	select grp_id
	from ttsgroupasgn
	where usr_userid = @user

/*   rol_type (U,G)    , rol_typeID   (user id or group id ), rol_ID (labelfile abbr for the Role label)*/
insert into @roles
	select distinct con_asgnrole
	from config_role_assignment
	where con_asgnuser = @user

insert into @roles
	select distinct con_asgnrole
	from config_role_assignment
	join @groups on con_asgngroup = grp_id
	
select distinct rol_id,name 
	From @roles rls
	join labelfile on rls.rol_id = labelfile.abbr and labeldefinition= 'ConfigurationRole'
	
GO
GRANT EXECUTE ON  [dbo].[d_getrole_sp] TO [public]
GO
