package fr.shizub.liquidglass;

import android.graphics.RuntimeShader;
import android.os.Build;
import android.util.Log;

/**
 * Shader AGSL du verre liquide : réfraction sur le bord (lentille), dispersion
 * chromatique, flou, teinte et reflet spéculaire qui suit l'inclinaison.
 * Nécessite Android 13 (API 33). En dessous, ou si la compilation échoue,
 * GlassView bascule sur un simple verre dépoli.
 */
final class GlassShader {

    static final String SOURCE =
            "uniform shader sharpTex;\n"
          + "uniform shader blurTex;\n"
          + "uniform float2 uSize;\n"
          + "uniform float2 uOrigin;\n"
          + "uniform float uRadius;\n"
          + "uniform float uBezel;\n"
          + "uniform float uRefraction;\n"
          + "uniform float uDispersion;\n"
          + "uniform float uBlurMix;\n"
          + "uniform float4 uTint;\n"
          + "uniform float uSpecular;\n"
          + "uniform float2 uLight;\n"
          + "\n"
          + "float sdRRect(float2 p, float2 b, float r) {\n"
          + "    float2 q = abs(p) - b + float2(r);\n"
          + "    return length(max(q, float2(0.0))) + min(max(q.x, q.y), 0.0) - r;\n"
          + "}\n"
          + "\n"
          + "half4 bg(float2 p) {\n"
          + "    return mix(sharpTex.eval(p), blurTex.eval(p), half(uBlurMix));\n"
          + "}\n"
          + "\n"
          + "half4 main(float2 fc) {\n"
          + "    float2 hs = uSize * 0.5;\n"
          + "    float2 p = fc - hs;\n"
          + "    float r = min(uRadius, min(hs.x, hs.y));\n"
          + "    float d = sdRRect(p, hs, r);\n"
          + "    float alpha = clamp(0.5 - d, 0.0, 1.0);\n"
          + "    if (alpha <= 0.0) { return half4(0.0); }\n"
          + "    float e = 0.75;\n"
          + "    float2 n = float2(sdRRect(p + float2(e, 0.0), hs, r) - sdRRect(p - float2(e, 0.0), hs, r),\n"
          + "                      sdRRect(p + float2(0.0, e), hs, r) - sdRRect(p - float2(0.0, e), hs, r));\n"
          + "    float nl = length(n);\n"
          + "    n = nl > 0.0001 ? n / nl : float2(0.0);\n"
          + "    float bezel = max(uBezel, 1.0);\n"
          + "    float t = clamp(1.0 + d / bezel, 0.0, 1.0);\n"
          + "    float bend = t * t * t;\n"
          + "    float2 offset = -n * bend * uRefraction;\n"
          + "    float2 base = uOrigin + fc;\n"
          + "    half4 col = bg(base + offset);\n"
          + "    if (uDispersion > 0.001) {\n"
          + "        col.r = bg(base + offset * (1.0 + uDispersion)).r;\n"
          + "        col.b = bg(base + offset * (1.0 - uDispersion)).b;\n"
          + "    }\n"
          + "    half3 rgb = mix(col.rgb, half3(uTint.rgb), half(uTint.a));\n"
          + "    float sheen = 0.07 * (1.0 - fc.y / uSize.y);\n"
          + "    float rim = smoothstep(0.45, 1.0, t);\n"
          + "    float lit = pow(max(dot(n, uLight), 0.0), 2.0) + 0.35 * pow(max(dot(n, -uLight), 0.0), 2.0);\n"
          + "    float edgeLine = smoothstep(0.82, 1.0, t) * 0.10;\n"
          + "    rgb += half3(sheen + rim * lit * uSpecular + edgeLine);\n"
          + "    rgb = clamp(rgb, half3(0.0), half3(1.0));\n"
          + "    return half4(rgb * half(alpha), half(alpha));\n"
          + "}\n";

    private static boolean failed;
    static String lastError;

    private GlassShader() {}

    static boolean supported() {
        return Build.VERSION.SDK_INT >= 33 && !failed;
    }

    /** Retourne un nouveau shader, ou null si le verre liquide n'est pas disponible. */
    static RuntimeShader create() {
        if (!supported()) return null;
        try {
            return new RuntimeShader(SOURCE);
        } catch (Throwable t) {
            failed = true;
            lastError = String.valueOf(t.getMessage());
            Log.e("LiquidGlass", "Shader AGSL refusé, repli sur le verre dépoli", t);
            return null;
        }
    }
}
