import "./index.css";
import { Composition } from "remotion";
import { SafeSightProposal } from "./Composition";

// 5 sections × 150 frames at 30fps = 25 seconds total
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="SafeSightLAISAProposal"
        component={SafeSightProposal}
        durationInFrames={750}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};