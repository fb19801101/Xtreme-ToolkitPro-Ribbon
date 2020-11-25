ALTER TABLE [tb_retest_rail]
    DROP COLUMN [rr_left_wfp15u_out]
GO

ALTER TABLE [tb_retest_rail]
    ADD [rr_left_wfp15u_out] [float] NOT NULL
GO

ALTER TABLE [tb_retest_rail]
DROP CONSTRAINT DF_tb_retest_rail_rr_left_wfp15u_out  

ALTER TABLE [tb_retest_rail] 
ADD CONSTRAINT DF_tb_retest_rail_rr_left_wfp15u_out  default 0 for	rr_left_wfp15u_out