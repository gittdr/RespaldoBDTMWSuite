SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CompileTariffSortKey]
(
    @keys AS dbo.IntInParm READONLY
)
AS
BEGIN

-- get restrictions not in the tariffkey table
DECLARE @NonKeyRestriction TABLE
( trk_number      INT
, tar_number      INT
, ApplyToAsset    VARCHAR(10)
, LoadRequirement CHAR(1) NULL
)

INSERT INTO @NonKeyRestriction(trk_number, tar_number, ApplyToAsset, LoadRequirement)
SELECT tariffkey.trk_number
    , tariffkey.tar_number
    , COALESCE(th.tar_applyto_asset, ths.tar_applyto_asset, 'UNK', 'N')
    , (CASE WHEN EXISTS (SELECT 1 FROM TariffKeyLoadRequirements l WHERE l.trk_number = tariffkey.trk_number) THEN 'Y' ELSE 'N' END)
FROM @keys keys
INNER JOIN tariffkey on tariffkey.trk_number = keys.intItem
LEFT OUTER JOIN tariffheader th ON tariffkey.tar_number = th.tar_number
LEFT OUTER JOIN tariffheaderstl ths ON tariffkey.tar_number = ths.tar_number

-- holds 4-value hashes of sortkey chunks
CREATE TABLE  #rosetta (
    fourDigit char(4)
    , single varchar(1)
);

INSERT INTO #rosetta (fourDigit, single)
VALUES
    ('0000', '2')
    ,('0001','3')
    ,('0010','4')
    ,('0011','5')
    ,('0100','6')
    ,('0101','7')
    ,('0110','8')
    ,('0111','9')
    ,('1000','A')
    ,('1001','B')
    ,('1010','C')
    ,('1011','D')
    ,('1100','E')
    ,('1101','F')
    ,('1110','G')
    ,('1111','H');

-- holds 4-value chunks of sortkey
CREATE TABLE  #tempTariffKey (
    trk_number int
    , sc1 char(4)
    , sc2 char(4)
    , sc3 char(4)
    , sc4 char(4)
    , sc5 char(4)
    , sc6 char(4)
    , sc7 char(4)
    , sc8 char(4)
    , sc9 char(4)
    , sc10 char(4)
    , sc11 char(4)
    , sc12 char(4)
    , sc13 char(4)
    , sc14 char(4)
    , sc15 char(4)
    , sc16 char(4)
    , sc17 char(4)
    , sc18 char(4)
    , sc19 char(4)
    , sc20 char(4)
    , sc21 char(4)
    , sc22 char(4)
    , sc23 char(4)
);

-- chunk sortkey from restrictions
INSERT INTO #tempTariffKey (
    trk_number
    , sc1
    , sc2
    , sc3
    , sc4
    , sc5
    , sc6
    , sc7
    , sc8
    , sc9
    , sc10
    , sc11
    , sc12
    , sc13
    , sc14
    , sc15
    , sc16
    , sc17
    , sc18
    , sc19
    , sc20
    , sc21
    , sc22
    , sc23
)
SELECT
    trk.trk_number

    , (CASE WHEN IsNull(trk.PrivateRestriction, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.MasterOrderNumber, '') = '' THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_billto, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_ratemode, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_servicelevel, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)								--4
    + (CASE WHEN IsNull(trk.cmp_mastercompany, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_id, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_number, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trl_number, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)					--8
    + (CASE WHEN IsNull(trk.mpp_payto, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_owner, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trl_owner, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)								--4

    , (CASE WHEN IsNull(trk.pto_id, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_orderedby, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN CONVERT(VARCHAR,IsNull(trk.rth_id,0)) = '0' THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_carrier, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)									--4

    , (CASE WHEN IsNull(trk.cmd_code, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.cmd_class, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trl_type1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trl_type2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)									--4

    , (CASE WHEN IsNull(trk.trl_type3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trl_type4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_type1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_type2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.mpp_type3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_type4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_type1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_type2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trc_type3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_type4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.cmp_othertype1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.cmp_othertype2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_originpoint, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN CONVERT(VARCHAR,IsNull(trk.trk_origincity,0)) = '0' THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_originzip, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_origincounty, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_originstate, 'XX') IN ('', 'XX') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_destpoint, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN CONVERT(VARCHAR,IsNull(trk.trk_destcity,0)) = '0' THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_destzip, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_destcounty, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_deststate, 'XX') IN ('', 'XX') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_revtype1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_revtype2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_revtype3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_revtype4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.cht_itemcode, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_company, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_lghtype1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_lghtype2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_lghtype3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_lghtype4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_load, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_team, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_boardcarrier, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_terms, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_triptype_or_region, 'X') IN ('', 'X') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_tt_or_oregion, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_dregion, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_thirdparty, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_thirdpartytype, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.billto_othertype1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.billto_othertype2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_terminal, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_mpp_company, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_mpp_fleet, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_mpp_division, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_mpp_domicile, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_mpp_teamleader, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trc_terminal, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_trc_company, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_trc_fleet, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_trc_division, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trl_terminal, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_trl_company, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_trl_fleet, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_trl_division, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_primary_driver, 'A') IN ('', 'A') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_ord_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_mpp_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)							--4

    , (CASE WHEN IsNull(trk.trk_trc_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_car_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_trl_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.trk_tpr_branch, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)

    , (CASE WHEN IsNull(sk.ApplyToAsset, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4
    + (CASE WHEN IsNull(trk.trk_route, 'UNKNOWN') IN ('', 'UNKNOWN') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.thirdpartytype1, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.thirdpartytype2, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)

    , (CASE WHEN IsNull(trk.thirdpartytype3, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)							--4
    + (CASE WHEN IsNull(trk.thirdpartytype4, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(sk.LoadRequirement, 'N') = 'N' THEN '0' ELSE '1' END)
    + (CASE WHEN IsNull(trk.mpp_TimeLogActivity, 'UNK') IN ('', 'UNK') THEN '0' ELSE '1' END)
FROM dbo.tariffkey trk
INNER JOIN @NonKeyRestriction sk ON trk.trk_number = sk.trk_number
INNER JOIN @keys AS keys ON trk.trk_number = keys.intItem

-- hash sortkey and update tariffkey
UPDATE z
SET
    z.trk_sortkey = b.single 
    + c.single
    + d.single
    + e.single
    + f.single
    + g.single
    + h.single
    + i.single
    + j.single
    + k.single
    + l.single
    + m.single
    + n.single
    + o.single
    + p.single
    + q.single
    + r.single
    + s.single
    + t.single
    + u.single
    + v.single
    + w.single
    + x.single
    + y.single
    + RIGHT('0000' + CONVERT(VARCHAR,(9999 - IsNull(z.trk_duplicateseq,0))),4)
FROM dbo.tariffkey z
INNER JOIN #tempTariffKey a ON z.trk_number = a.trk_number
INNER JOIN #rosetta b ON b.fourDigit = A.SC1           
INNER JOIN #rosetta c ON c.fourDigit = A.SC2           
INNER JOIN #rosetta d ON d.fourDigit = A.SC3           
INNER JOIN #rosetta e ON e.fourDigit = A.SC4           
INNER JOIN #rosetta f ON f.fourDigit = A.SC5           
INNER JOIN #rosetta g ON g.fourDigit = A.SC6           
INNER JOIN #rosetta h ON h.fourDigit = A.SC7           
INNER JOIN #rosetta i ON i.fourDigit = A.SC8           
INNER JOIN #rosetta j ON j.fourDigit = A.SC9           
INNER JOIN #rosetta k ON k.fourDigit = A.SC10           
INNER JOIN #rosetta l ON l.fourDigit = A.SC11           
INNER JOIN #rosetta m ON m.fourDigit = A.SC12          
INNER JOIN #rosetta n ON n.fourDigit = A.SC13         
INNER JOIN #rosetta o ON o.fourDigit = A.SC14          
INNER JOIN #rosetta p ON p.fourDigit = A.SC15          
INNER JOIN #rosetta q ON q.fourDigit = A.SC16          
INNER JOIN #rosetta r ON r.fourDigit = A.SC17          
INNER JOIN #rosetta s ON s.fourDigit = A.SC18          
INNER JOIN #rosetta t ON t.fourDigit = A.SC19          
INNER JOIN #rosetta u ON u.fourDigit = A.SC20          
INNER JOIN #rosetta v ON v.fourDigit = A.SC21           
INNER JOIN #rosetta w ON w.fourDigit = A.SC22
INNER JOIN #rosetta x ON w.fourDigit = A.SC22
INNER JOIN #rosetta y ON y.fourDigit = A.SC23

-- cleanup
DROP TABLE #rosetta;
DROP TABLE #tempTariffKey;

END
GO
GRANT EXECUTE ON  [dbo].[sp_CompileTariffSortKey] TO [public]
GO
