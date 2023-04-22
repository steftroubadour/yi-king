// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Initializable } from "src/utils/Initializable.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title images for Yi Jing App & NFT
contract YiJingImagesGenerator is Initializable {
    string constant SVG_DEFS =
        '<defs><radialGradient id="def1"> <stop offset="20%" stop-color="white" /> <stop offset="100%" stop-color="gold" /> </radialGradient> <radialGradient id="GradientReflect" cx="0.5" cy="0.5" r="0.4" fx="0.75" fy="0.75" spreadMethod="reflect"><stop offset="0%" stop-color="red"/><stop offset="100%" stop-color="blue"/></radialGradient></defs>';
    string constant SVG_STYLE =
        "<style> svg {filter: drop-shadow(3px 5px 2px rgb(0 0 0 / 0.4));}svg text {font: italic 6px sans-serif; text-anchor: middle;}</style>";
    string constant SVG_ONE_STYLE =
        "<style> svg {filter: drop-shadow(2px 3px 1px rgb(0 0 0 / 0.3));}</style>";
    string constant PATH_BEGIN = '<path d="M-16,-';
    string constant PATH_END = '" fill="black" stroke="black"/>';
    string constant NEW_YIN = "h12v2h-12Zm20,0h12v2h-12Z";
    string constant NEW_YANG = "h32v2h-32Z";
    string constant OLD_YIN = "h12v2h-12Zm14,-1.5l4,5m-4,0l4,-5m2,1.5h12v2h-12Z";
    string constant OLD_YANG_PART_ONE =
        'h13v2h-13Zm19,0h13v2h-13Z" fill="black" stroke="black"/><circle cx="0" cy="-';
    string constant OLD_YANG_PART_TWO =
        '" r="2.5" fill="transparent" fill-opacity="0" stroke="black"/>';
    string constant TAIJITU =
        '<g class="taijitu"><circle r="39"/><path fill="#fff" d="M0,38a38,38 0 0 1 0,-76a19,19 0 0 1 0,38a19,19 0 0 0 0,38"/><circle r="5" cy="19" fill="#fff"/><circle r="5" cy="-19"/><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 0 0" to="360 0 0" dur="5s" repeatCount="indefinite"/></g>';
    string constant YI_JING =
        '<path id="yijing" d="m-60 148c-4 1-7 1-11 1-3 1-7 1-10 1 0 2-1 4-1 6 3 2 4 4 3 4 0 1-1 2-3 3 13-1 23-2 30-2 6-1 11-2 13-3 3-1 5 0 8 2 2 2 5 4 7 6 3 2 3 4 1 5-1 1-3 4-4 9-2 5-3 11-6 18-2 7-5 12-9 15-3 3-7 6-11 7-4 2-6 1-6-1 0-3-2-6-7-11-5-4-4-5 3-2 6 4 11 3 15 0 4-4 7-10 10-19 3-8 4-14 3-18-1-3-4-5-8-5-3 0-8 1-16 1 6 5 8 8 6 10-2 1-5 4-9 8-4 5-10 11-19 17-8 6-15 9-21 11-6 1-7 1-2-1 5-3 10-7 17-13 7-6 13-11 18-16 4-5 6-10 7-16-7 1-12 2-16 2 1 2 2 3 4 5 1 1 1 2-1 3-1 0-5 3-10 7-5 4-10 7-16 8-5 1-5 1-1-2 4-2 9-5 13-9 5-4 8-8 9-12l-5-1c-9 6-17 10-23 13-7 2-7 1-1-2 6-4 11-7 14-10 3-4 7-7 10-11-1-8-1-15-1-23-1-8-2-13-4-16-3-4-2-5 2-5 3 1 9 1 16 0 7-1 11-3 12-4 2-1 5 0 9 2 4 2 6 3 5 4 0 2-1 4-3 7-1 3-1 8-1 14 0 7-1 12-3 15-2 4-3 6-4 6 0-1-1-3-3-8zm-21-2 12-2c3 0 6 0 7 1 2 0 3 0 4-1 1-2 1-6 1-15 0-8 0-13-1-14-1-1-4-2-8-1-4 1-9 2-15 3l0 13c4-1 7-2 10-3 2-1 5 0 7 1 2 2 0 3-4 4-5 1-9 1-13 1v13zm165-1c15 3 24 6 28 10 4 4 6 7 5 11 0 3-3 3-8-1-5-3-14-9-26-18-3 3-6 7-11 10-3 4-8 7-15 9-6 3-6 1 2-4 7-6 14-13 20-20 5-8 8-13 9-17-5 1-9 2-14 4-5 2-9 2-12 0-3-2-3-3 1-3 5-1 10-2 16-3 7-2 10-4 11-5 1-1 3-1 5 0 2 1 4 2 6 4 2 1 2 3-1 4-2 1-4 4-7 7-2 4-5 8-9 12zm-1 32c3 1 4 3 3 5-1 3-2 8-2 17 12-1 19-2 23-3 4-1 8 0 11 3 3 3 2 4-3 4-5 0-10 0-15 0-5 0-13 0-22 2-10 1-17 2-20 3-3 1-7 0-11-2-4-3-4-4 0-4 4 0 15-1 31-3 0-12-1-19-1-20 0-1-2-1-6-1-3 0-6 0-9-1-3-2-2-3 1-3 3 0 7-1 11-2 4-1 9-2 15-3 6-2 10-2 12-1 3 2 3 3-1 4-3 2-9 3-17 5zm-45-30c5-8 8-13 7-16 0-3 0-4 3-3 3 2 5 3 6 5 2 1 1 3-2 6-2 2-10 11-22 28 9-1 15-2 19-2 4-1 2 1-7 4-8 4-14 7-17 9-3 2-5 1-6-2-1-3 0-6 2-7 2-1 7-7 15-19-10 2-16 3-17 5-2 1-3 1-4-3-1-3 0-5 2-5 2-1 4-3 6-6 2-3 4-7 6-13 2-5 2-9 1-12-1-3 0-4 2-3 3 1 5 2 7 5 2 1 2 3 0 5-2 1-6 10-14 24h13zm-2 40c16-5 18-5 7 1-10 7-16 11-19 13-2 2-5 1-10-2-4-4-4-6 0-6 4 0 12-2 22-6z" fill="black"/>';

    string constant YI_JING_ANIMATION =
        '<path d="m3-2-3-14-3 14-9 2 9 2 3 13 3-13 9-2-9-2z" fill="url(#def1)"><animateTransform attributeName="transform" attributeType="XML" type="scale" values="0;0.5;0" dur="1s" repeatCount="indefinite"/><animateMotion dur="60s" repeatCount="indefinite"><mpath xlink:href="#yijing"/></animateMotion></path>';
    string constant CARD =
        '<rect id="square" x="-200" y="-240" width="400" height="480" rx="15" ry="15" fill="pink" fill-opacity="0.3" stroke="url(#GradientReflect)" stroke-width="6" stroke-opacity="0.7"/>';
    uint256 constant V_BASE_POSITION = 32;

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    function _getNewYin(uint8 position) internal pure returns (string memory) {
        return
            string.concat(
                PATH_BEGIN,
                Strings.toString(V_BASE_POSITION + 7 * position),
                NEW_YIN,
                PATH_END
            );
    }

    function _getNewYang(uint8 position) internal pure returns (string memory) {
        return
            string.concat(
                PATH_BEGIN,
                Strings.toString(V_BASE_POSITION + 7 * position),
                NEW_YANG,
                PATH_END
            );
    }

    function _getOldYin(uint8 position) internal pure returns (string memory) {
        return
            string.concat(
                PATH_BEGIN,
                Strings.toString(V_BASE_POSITION + 7 * position),
                OLD_YIN,
                PATH_END
            );
    }

    function _getOldYang(uint8 position) internal pure returns (string memory) {
        return
            string.concat(
                PATH_BEGIN,
                Strings.toString(V_BASE_POSITION + 7 * position),
                OLD_YANG_PART_ONE,
                Strings.toString(V_BASE_POSITION - 1 + 7 * position),
                OLD_YANG_PART_TWO
            );
    }

    function _getTrait(uint8 value, uint8 position) internal pure returns (string memory) {
        string memory trait;
        if (value == 0) {
            trait = _getNewYin(position);
        } else if (value == 1) {
            trait = _getNewYang(position);
        } else if (value == 2) {
            trait = _getOldYin(position);
        } else {
            assert(value == 3);
            trait = _getOldYang(position);
        }

        return string.concat('<g class="', Strings.toString(position + 1), '">', trait, "</g>");
    }

    function _getText(
        uint8[6] memory lines,
        uint8 variation
    ) internal pure returns (string memory) {
        string memory text;
        if (variation == 0) {
            text = "draw";
        } else if (variation == 1) {
            text = string.concat("from ", Strings.toString(_getNumber(lines)));
        } else {
            assert(variation == 2);
            text = string.concat("to ", Strings.toString(_getNumber(lines)));
        }

        return
            string.concat(
                '<text x="0" y="-',
                Strings.toString(V_BASE_POSITION - 12),
                '" class="small">',
                text,
                "</text>"
            );
    }

    function _getAnimationTransform(string memory params) internal pure returns (string memory) {
        return
            string.concat(
                '<animateTransform attributeName="transform" attributeType="XML" ',
                params,
                ' dur="20s" repeatCount="indefinite"/>'
            );
    }

    function _getRotateAnimation(
        string memory from,
        string memory to
    ) internal pure returns (string memory) {
        return
            _getAnimationTransform(
                string.concat('type="rotate" from="', from, ' 0 0" to="', to, ' 0 0"')
            );
    }

    function _getScaleAnimation(string memory values) internal pure returns (string memory) {
        return
            _getAnimationTransform(
                string.concat('type="scale" calcMode="linear" values="', values, '" additive="sum"')
            );
    }

    function _getAnimations(uint8 variation) internal pure returns (string memory) {
        if (variation == 1)
            return
                string.concat(
                    _getRotateAnimation("-120", "240"),
                    _getScaleAnimation("1;2;3;2;1;0.5;1")
                );
        if (variation == 2)
            return
                string.concat(
                    _getRotateAnimation("-240", "120"),
                    _getScaleAnimation("1;0.5;1;2;3;2;1")
                );
        assert(variation == 0);
        return
            string.concat(_getRotateAnimation("0", "360"), _getScaleAnimation("3;2;1;0.5;1;2;3"));
    }

    function _getThe6Bits(
        uint8[6] memory lines,
        uint8 variation
    ) internal pure returns (uint8[6] memory) {
        if (variation == 1) return _getFrom6Bits(lines);
        if (variation == 2) return _getTo6Bits(lines);
        assert(variation == 0);
        return lines;
    }

    function _getGroups(uint8[6] memory lines) internal pure returns (string[3] memory) {
        //slither-disable-next-line uninitialized-local
        string[3] memory svg;
        for (uint8 variation = 0; variation < 3; variation++) {
            uint8[6] memory the6Bits = _getThe6Bits(lines, variation);
            svg[variation] = "<g>";
            for (uint8 id; id < 6; id++) {
                svg[variation] = string.concat(svg[variation], _getTrait(the6Bits[5 - id], 5 - id));
            }

            svg[variation] = string.concat(
                svg[variation],
                _getText(the6Bits, variation),
                _getAnimations(variation),
                "</g>"
            );
        }

        return svg;
    }

    function _getSVG(uint8[6] memory lines) internal pure returns (string memory) {
        string[3] memory groups = _getGroups(lines);
        string memory svg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="512" height="512" viewBox="-256 -256 512 512">',
            SVG_DEFS,
            SVG_STYLE,
            CARD
        );
        for (uint8 variation = 0; variation < 3; variation++) {
            svg = string.concat(svg, groups[variation]);
        }

        return string.concat(svg, TAIJITU, YI_JING, YI_JING_ANIMATION, "</svg>");
    }

    function _getFrom6Bits(uint8[6] memory lines) internal pure returns (uint8[6] memory) {
        //slither-disable-next-line uninitialized-local
        uint8[6] memory from6Bits;
        for (uint8 i = 0; i < 6; i++) {
            from6Bits[i] = lines[i] % 2;
        }

        return from6Bits;
    }

    function _getTo6Bits(uint8[6] memory lines) internal pure returns (uint8[6] memory) {
        //slither-disable-next-line uninitialized-local
        uint8[6] memory to6Bits;
        for (uint8 i = 0; i < 6; i++) {
            to6Bits[i] = (lines[i] == 0 || lines[i] == 3) ? (lines[i] + 1) % 2 : lines[i] % 2;
        }

        return to6Bits;
    }

    // Use the King Wen sequence
    // https://oeis.org/A102241
    function _getNumber(uint8[6] memory a6Bits) internal pure returns (uint256) {
        // Inverse of the King Wen sequence
        uint8[64] memory from6BitsToNumber = [
            2,
            24,
            7,
            19,
            15,
            36,
            46,
            11,
            16,
            51,
            40,
            54,
            62,
            55,
            32,
            34,
            8,
            3,
            29,
            60,
            39,
            63,
            48,
            5,
            45,
            17,
            47,
            58,
            31,
            49,
            28,
            43,
            23,
            27,
            4,
            41,
            52,
            22,
            18,
            26,
            35,
            21,
            64,
            38,
            56,
            30,
            50,
            14,
            20,
            42,
            59,
            61,
            53,
            37,
            57,
            9,
            12,
            25,
            6,
            10,
            33,
            13,
            44,
            1
        ];

        uint256 n = (a6Bits[5] << 5) +
            (a6Bits[4] << 4) +
            (a6Bits[3] << 3) +
            (a6Bits[2] << 2) +
            (a6Bits[1] << 1) +
            (a6Bits[0] << 0);

        return from6BitsToNumber[n];
    }

    /*/////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    //////////////////////////////////////////////////// */

    /// Retrieve base64 hexagram image for a variation
    /// @param lines an hexagram is composed by 6 lines defined by a number in the range [0;3]
    /// @param variation 0 is 'Draw' hexagram, 1 is for 'From' hexagram and 2 is for 'To' hexagram
    /// @return uint256 hexagram number
    /// @return string svg base64 image
    function getHexagramImageForVariation(
        uint8[6] memory lines,
        uint8 variation
    ) external pure returns (uint256, string memory) {
        uint8[6] memory the6Bits = _getThe6Bits(lines, variation);
        string memory svg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="46" height="46" viewBox="-23 -76 46 56">',
            SVG_ONE_STYLE
        );
        for (uint8 id = 0; id < 6; id++) {
            svg = string.concat(svg, _getTrait(the6Bits[5 - id], 5 - id));
        }

        svg = string.concat(svg, "</svg>");

        // svg Data
        svg = string.concat("data:image/svg+xml;base64,", Base64.encode(abi.encodePacked(svg)));

        return (variation == 0 ? 0 : _getNumber(the6Bits), svg);
    }

    /// Retrieve base64 image for NFT
    /// @param lines an hexagram is composed by 6 lines defined by a number in the range [0;3]
    /// @return string svg base64 image
    function getNftImage(uint8[6] memory lines) external view returns (string memory) {
        return (
            string.concat(
                "data:image/svg+xml;base64,",
                Base64.encode(abi.encodePacked(_getSVG(lines)))
            )
        );
    }
}
